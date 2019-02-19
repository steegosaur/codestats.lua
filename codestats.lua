#!/usr/bin/env lua5.3
-- codestats.lua 1.5.0 - analyze source code
-- Copyright Stæld Lakorv, 2010-2013; 2019 <staeld@illumine.ch>
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
-- }}}

-- {{{ Sanity check
if not arg[1] then
    err(msg.noarg)
elseif arg[1] == "--help" then
    msg.help()
    os.exit()
end
-- }}}
-- {{{ Read command line input flags and files
for i, flag in ipairs(arg) do
    if flag:match("^[^-]") then
        -- Flag is not a switch; assume input file
        -- Add file to the input files list
        local inFile = arg[i]
        inFiles[inFile] = {}
        if not io.open(inFile, "r") then err(msg.nofile, inFile) end
        io.input(inFile)
        local h
        repeat -- TODO: Check if this is actually needed or just really stupid
            h = io.read()
        until h
        io.close()
        -- flang can be set several times; always use the latest one
        --+ This should allow for use like `--lua test.lua --py test.py test2.py`
        if not flang then
            for _, lang in pairs(langs) do -- Check for header
                if lang.header and h:match("^" .. lang.header) then
                    -- print(msg.lFound .. "header") -- Debuggers are for people who know what they're doing
                    flang = lang
                    break
                end
            end
        end
        if not flang then -- Header not found; may be non-interpreted or without one
            ending = inFile:match("[%w%p%s]+%.(%w+)$")
            for _, lang in ipairs(langs) do -- Check for file ending in filename
                if ending:match(lang.ending) then
                    -- print(msg.lFound .. "ending") -- What is debugging even
                    flang = lang
                    break
                end
            end
        end
        if not flang then err(msg.noarg) end -- Couldn't determine the language
        inFiles[inFile].flang = flang
    elseif flag:match("^%-%-") then
        -- Flag *is* a switch
        flag = flag:lower():gsub("^%-%-", "")
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
    if first then first = false
    elseif not dosumonly then print("\n----\n") end
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
        if verbose then
            -- Analyse licence, ownership and more
            if ( longComment == true
              or ( flang.comment and line:match(flang.comment) )
              or ( flang.xomment and line:match(flang.xomment) ) )
              -- We assume the licence comes before the code; read if not exists
              -- and stats[inFile].lcount == 0 then -- FIXME: Doesn't work for some reason
            then
                if not stats[inFile].copyright then stats[inFile].copyright = getAuthor(line) end
                if not stats[inFile].licence   then stats[inFile].licence   = getLicence(line) end
                if not stats[inFile].version   then stats[inFile].version   = getLicenceVersion(line) end
            end
        end
    end
    -- }}}
    -- {{{ Present data
    stats[inFile].tcount = stats[inFile].ccount + stats[inFile].lcount + stats[inFile].ecount + stats[inFile].xcount  -- Total count
    local bytes
    stats[inFile].size, bytes = getSize(f)
    if not dosumonly then
        stats[inFile] = stats.percent(stats[inFile]) -- Add the percentages to the table (replaces it with updated version
        stats.print(inFile)
    end
    if dosummary or dosumonly then
        for _, s in ipairs({"tcount", "ccount", "ecount", "xcount", "lcount"}) do
            stats._total[s] = stats._total[s] + stats[inFile][s]
        end
        stats._total.bytes = stats._total.bytes + bytes
    end
    -- }}}
end
-- Do the summary if required
if dosummary or dosumonly then
--    if not first then print("\n----\n") end -- Uncomment to make summaries pretty; comment to make sumonly pretty
    print("Total summary\n")
    stats._total = stats.percent(stats._total)
    stats._total.size = getSize(stats._total.bytes)
    stats.print("_total", true)
end
-- EOF
