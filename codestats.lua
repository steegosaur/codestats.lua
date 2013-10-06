#!/usr/bin/env lua
-- codestats.lua 1.5.0 - analyze source code
-- Copyright Stæld Lakorv, 2010-2013 <staeld@illumine.ch>
-- Released under GPLv3+

-- {{{ Functions, vars
langs   = {}
stats   = {}
file    = { "config", "funcs", "langs" }
inFiles = {} -- Container that keeps the files we'll analyse

-- Internal error handling, prettier than error()
function err(m, f)
    if not f then f = "" end
    print("error: " .. m .. f)
    os.exit(1)
end
-- }}}

-- {{{ Init
for _, f in ipairs(file) do require(f) end  -- Get the required files
-- Generate list of valid languages for use in help message
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
        -- Add file to the input files list
        local inFile = arg[i]
        inFiles[inFile] = {}
        if not io.open(inFile, "r") then err(msg.nofile, inFile) end
        io.input(inFile)
        local h
        repeat
            h = io.read()
        until h
        io.close()
        -- flang can be set several times; always use the latest one
        --+ This should allow for use like `--lua test.lua --py test.py test2.py`
        if not flang then
            for _, lang in pairs(langs) do -- Check for header
                if lang.header and h:match("^" .. lang.header) then
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
        if not flang then err(msg.noarg) end    -- We couldn't determine the language
        inFiles[inFile].flang = flang
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
        if not recognised then -- it was probably a language
            for _, lang in ipairs(langs) do
                if flag == lang.name or flag:match("^" .. lang.ending .. "$") then
                    flang = lang
                    recognised = true
                    break
                end
            end
        end
        if not recognised then err(msg.noarg) end
    end
end
-- }}}

local first = true
for inFile, t in pairs(inFiles) do
    if first then
        first = false
    else
        print("\n----\n")
    end
    stats[inFile] = {
        header = "no", -- Changed if found later
        lcount = 0, -- Lines of code
        ccount = 0, -- Comments
        xcount = 0, -- Comments of special type
        tcount = 0, -- Total
        ecount = 0, -- Empty
        total  = {}
    }
    local flang = t.flang
    -- {{{ Analyze
    f = io.open(inFile, "r")
    for line in f:lines() do
        if line:match("^%s-$")      -- Empty line, with or without comment signs
          or line:match("^%s-" .. flang.comment .. "%s-$") or
          -- Following commented out because they will bug handling of longcomment
    --    ( flang.longOpen and line:match("^%s-" .. flang.comment .. "%s-$") ) or
    --    ( flang.longEnd  and line:match("^%s-" .. flang.comment .. "%s-$") ) or
          ( flang.xomment  and line:match("^%s-" .. flang.xomment .. "%s-$") ) then
            stats[inFile].ecount = stats[inFile].ecount + 1
        elseif longComment == true then       -- Currently in a long comment
            stats[inFile].ccount = stats[inFile].ccount + 1
            if line:match(flang.longEnd) then -- End of longcomment
                longComment = false
            end
        elseif flang.header         -- We know of a header for the language
          and stats[inFile].lcount == 0     -- There have been no lines of code yet
          and line:match(flang.header) then
            stats[inFile].header = "yes"
        elseif flang.longOpen       -- Language has longcomment feature
          and line:match(flang.longOpen)
          and line:match(flang.longEnd) then  -- Open/close on a single line
            stats[inFile].ccount = stats[inFile].ccount + 1
        elseif flang.longOpen
          and line:match(flang.longOpen) then -- Longcomment start
            longComment = true
            stats[inFile].ccount = stats[inFile].ccount + 1
        elseif flang.xomment
          and line:match("^%s-" .. flang.xomment) then -- Other type of comment
            stats[inFile].xcount = stats[inFile].xcount + 1  -- Should these be combined?
        elseif flang.comment
          and line:match("^%s-" .. flang.comment) then -- Line is a comment
            stats[inFile].ccount = stats[inFile].ccount + 1
        else
            stats[inFile].lcount = stats[inFile].lcount + 1  -- Line is code
        end
        -- Analyse licence, ownership and more
        if ( longComment == true
          or ( flang.comment and line:match(flang.comment) )
          or ( flang.xomment and line:match(flang.xomment) ) )
          -- We presume the licence comes before the code; read if not exists
          and stats[inFile].lcount == 0 then
            if not copyright then copyright = getAuthor(line) end
            if not licence   then licence   = getLicence(line) end
            if not version   then version   = getLicenceVersion(line) end
        end
    end
    -- }}}
    
    -- {{{ Present data
    stats[inFile].tcount = stats[inFile].ccount + stats[inFile].lcount + stats[inFile].ecount + stats[inFile].xcount  -- Total count
    stats[inFile].cperc = round(( stats[inFile].ccount * 100 ) / stats[inFile].tcount)  -- Comments
    stats[inFile].eperc = round(( stats[inFile].ecount * 100 ) / stats[inFile].tcount)  -- Empty
    stats[inFile].xperc = round(( stats[inFile].xcount * 100 ) / stats[inFile].tcount)  -- Extra comments
    stats[inFile].lperc = round(100 - ( stats[inFile].cperc + stats[inFile].eperc + stats[inFile].xperc)) -- Code
    stats[inFile].tperc = round(stats[inFile].lperc + stats[inFile].eperc + stats[inFile].cperc + stats[inFile].xperc)
    stats[inFile].size  = getSize(f)
    stats.print(inFile)
    -- }}}
end
-- EOF
