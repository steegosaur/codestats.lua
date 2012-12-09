#!/usr/bin/env lua
-- codestats.lua 1.4-beta - analyze source code
-- Copyright Stæld Lakorv, 2010-2012 <staeld@illumine.ch>
-- Released under GPLv3+
-- {{{ Functions, vars
langs = {}
file = { "config", "funcs", "langs" }
stats = {
    header = "no", -- Changed if found later
    lcount = 0, -- Lines of code
    ccount = 0, -- Comments
    xcount = 0, -- Comments of special type
    tcount = 0, -- Total
    ecount = 0, -- Empty
    total  = {},
}

function err(m, f)
    if not f then f = "" end
    print("error: " .. m .. f)
    os.exit(1)
end
-- }}}

-- {{{ Init
for _, f in ipairs(file) do require(f) end
for _, lang in ipairs(langs) do
    if not langs.list then
        langs.list = lang.name
    else
        langs.list = langs.list .. " " .. lang.name
    end
end

-- Read version and usage from self
io.input(arg[0])
name = ""
while not name:match("^%-%-%s-(codestats%.lua.*)$") or not io.read() do
    name = io.read()
end
io.close()
name = name:gsub("^%W*", "")
msg = {
    noarg  = "invalid arguments given. See --help for more info.",
    nofile = "cannot open file ",
    lFound = "language recognised by means of ", -- for debug purposes
    help   = function()
        print(name)
        print("Usage: " .. arg[0] .. " [FLAG] [FILE]\n")
        print("Valid flags: --LANG  analyze source code parsing it as LANG")
        print("             --help  this help message\n")
        print("Valid LANGs: " .. langs.list)
    end
}
-- }}}

-- {{{ Sanity check
if not arg[1] then
    err(msg.noarg)
elseif arg[1] == "--help" then
    msg.help()
    os.exit()
end

-- Check and apply other flags
for i, flag in ipairs(arg) do
    if flag:match("^[^-]") then
        -- Flag is not a switch; presume input file
        inFile = arg[i]
        if not io.open(inFile, "r") then err(msg.nofile, inFile) end
        io.input(inFile)
        local h
        repeat
            h = io.read()
        until h
        io.close()
        if not flang then
            for _, lang in pairs(langs) do -- Check for header
                if lang.header and h:match(lang.header) then
                    -- print(msg.lFound .. "header")
                    flang = lang
                    break
                end
            end
        end
        if not flang then -- Header not found; may be non-interpreted or without
            ending = inFile:match("[%w%p%s]+%.(%w+)$")
            for _, lang in ipairs(langs) do -- Check for file ending in filename
                if ending:match(lang.ending) then
                    -- print(msg.lFound .. "ending")
                    flang = lang
                    break
                end
            end
        end
    elseif flag:match("^%-%-") then
        -- Flag *is* a switch
        flag = flag:gsub("^%-%-", "")
        local recognised = false
        for f in pairs(flags) do
            if flag == f then
                flags.activate(flag)
                recognised = true
                break
            end
        end
        if not recognised then
            for _, lang in ipairs(langs) do
                if flag == lang.name or flag:match(lang.ending) then
                    flang = lang
                    recognised = true
                    break
                end
            end
        end
        if not recognised then
            err(msg.noarg)
        end
    end
end
if not flang then err(msg.noarg) end
-- }}}

-- {{{ Analyze
f = io.open(inFile, "r")
for line in f:lines() do
    if line:match("^%s-$")      -- Empty line, with or without comment signs
      or line:match("^%s-" .. flang.comment .. "%s-$") or
      -- Following commented out because they will bug handling of longcomment
--    ( flang.longOpen and line:match("^%s-" .. flang.comment .. "%s-$") ) or
--    ( flang.longEnd  and line:match("^%s-" .. flang.comment .. "%s-$") ) or
      ( flang.xomment  and line:match("^%s-" .. flang.xomment .. "%s-$") ) then
        stats.ecount = stats.ecount + 1
    elseif longComment == true then       -- Currently in a long comment
        stats.ccount = stats.ccount + 1
        if line:match(flang.longEnd) then -- End of longcomment
            longComment = false
        end
    elseif flang.header         -- We know of a header for the language
      and stats.lcount == 0     -- There have been no lines of code yet
      and line:match(flang.header) then
        stats.header = "yes"
    elseif flang.longOpen       -- Language has longcomment feature
      and line:match(flang.longOpen)
      and line:match(flang.longEnd) then  -- Open/close on a single line
        stats.ccount = stats.ccount + 1
    elseif flang.longOpen
      and line:match(flang.longOpen) then -- Longcomment start
        longComment = true
        stats.ccount = stats.ccount + 1
    elseif flang.xomment
      and line:match(flang.xomment) then -- Other type of comment
        stats.xcount = stats.xcount + 1  -- Should these be combined?
    elseif flang.comment
      and line:match(flang.comment) then -- Line is a comment
        stats.ccount = stats.ccount + 1
    else
        stats.lcount = stats.lcount + 1  -- Line is code
    end
    -- Analyse licence, ownership and more
    if ( longComment == true
      or ( flang.comment and line:match(flang.comment) )
      or ( flang.xomment and line:match(flang.xomment) ) )
      -- We presume the licence comes before the code; read if not exists
      and stats.lcount == 0 then
        if not copyright then copyright = getAuthor(line) end
        if not licence   then licence   = getLicence(line) end
        if not version   then version   = getLicenceVersion(line) end
    end
end
-- }}}

-- {{{ Present data
stats.tcount = stats.ccount + stats.lcount + stats.ecount + stats.xcount  -- Total count
stats.cperc = round(( stats.ccount * 100 ) / stats.tcount)  -- Comments
stats.eperc = round(( stats.ecount * 100 ) / stats.tcount)  -- Empty
stats.xperc = round(( stats.xcount * 100 ) / stats.tcount)  -- Extra comments
stats.lperc = round(100 - ( stats.cperc + stats.eperc + stats.xperc)) -- Code
stats.tperc = round(stats.lperc + stats.eperc + stats.cperc + stats.xperc)
stats.size  = getSize(f)
stats.print()
-- }}}
-- EOF
