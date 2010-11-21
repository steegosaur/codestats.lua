#!/usr/bin/env lua
-- codestats.lua 1.3.0 - analyze source code
-- Copyright Stæld Lakorv, 2010 <staeld@staeld.co.cc>
-- Released under GPLv3+
-- {{{ Init
langs = { file = "langs" }
function err(m, f)
    if not f then f = "" end
    print("error: " .. m .. f)
    os.exit(1)
end
if not io.open(langs.file .. ".lua", "r") then
    err("unable to open config file ", langs.file .. ".lua")
end
require(langs.file)
for i = 1, #langs do
    if not langs.list then
        langs.list = langs[i].name
    else
        langs.list = langs.list .. " " .. langs[i].name
    end
end
-- Read version and usage from self
io.input(arg[0])
name = ""
while not string.match(name, "^%-%-%s-(codestats%.lua.*)$") or not io.read() do
    name = io.read()
end
io.close()
name = string.gsub(name, "^%W*", "")
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
stats = {
    header = "no", -- Changed if found later
    lcount = 0, -- Lines of code
    ccount = 0, -- Comments
    xcount = 0, -- Comments of special type
    tcount = 0, -- Total
    ecount = 0  -- Empty
}
-- functions
function balancePrint(offset, t, stat)
    print(t .. string.rep(" ", offset - ( string.len(t) + string.len(stat) )) .. stat)
end
function stats.print()
    local s = {
        { name = "File", data = inFile },
        { name = "Size", data = stats.size },
        { name = "Language", data = langs[lnum].name }
    }
    if langs[lnum].header then
        table.insert(s, { name = "Header", data = stats.header })
    end
    for i = 1, #s do
        balancePrint(30, s[i].name .. " ", s[i].data)
    end
    print()
    local d = {
        { name = "Code",    count = "lcount", perc = "lperc" },
        { name = "Comment", count = "ccount", perc = "cperc" },
        { name = "Empty",   count = "ecount", perc = "eperc" },
        { name = "Total",   count = "tcount", perc = "tperc" }
    }
    if langs[lnum].xomment then
        table.insert(d, 3, { name = "Comment #2", count = "xcount", perc = "xperc" })
    end
    for i = 1, #d do
        print(d[i].name .. string.rep(" ", 18 - ( string.len(d[i].name) + string.len(stats[d[i].count]) )) .. stats[d[i].count] .. " (" .. string.rep(" ", 6 - string.len(stats[d[i].perc])) .. stats[d[i].perc] .. " % )")
    end
end
function round(n)
    n = string.format("%.1f", n)
    return n
end
function getSize(f)
    if not ( type(f) == "userdata" ) then
        err("could not read file handle in function getSize()")
    end
    local l = f:seek("end")
    if ( l >= 1048576 ) then
        l = l / 1048576
        unit = "MiB"
    elseif ( l >= 1024 ) then
        l = l / 1024
        unit = "kiB"
    else
        unit = "B"
    end
    l = string.format("%.1f " .. unit, l)
    return l
end
-- }}}

-- {{{ Sanity check
if not arg[1] then
    err(msg.noarg)
elseif ( arg[1] == "--help" ) then
    msg.help()
    os.exit()
end

-- First check if a language has been forced - we don't want to overrule the user!
if ( string.sub(arg[1], 1, 2) == "--" ) then
    for i = 1, #langs do
        if ( arg[1] == "--" .. langs[i].name ) then
            -- print(msg.lFound .. "command-line flag")
            lnum = i
            inFile = arg[2]
        end
    end
    if not lnum then err(msg.noarg) end -- LANG is not a supported language
else -- LANG not specified, check for file header, then for file ending
    inFile = arg[1] -- no --LANG means arg[1] should be a file; check:
    if not io.open(inFile, "r") then err(msg.nofile, inFile) end
    io.input(inFile)
    local h
    repeat
        h = io.read()
    until h
    io.close()
    for i = 1, #langs do -- Check for header
        if langs[i].header and string.match(h, langs[i].header) then
            -- print(msg.lFound .. "header")
            lnum = i
            break
        end
    end
    if not lnum then -- Header not found; may be non-interpreted or without
        ending = string.match(inFile, "[%w%p%s]+%.(%w+)$")
        for i = 1, #langs do -- Check for file ending in filename
            if string.match(ending, langs[i].ending) then
                -- print(msg.lFound .. "ending")
                lnum = i
                break
            end
        end
    end
end
if not lnum then err(msg.noarg) end
-- }}}

-- {{{ Analyze
f = io.open(inFile, "r")
for line in f:lines() do
    if ( longComment == true ) then
        stats.ccount = stats.ccount + 1
        if string.match(line, langs[lnum].longEnd) then
            longComment = false
        end
    elseif langs[lnum].header   and ( stats.lcount == 0 ) and string.match(line, langs[lnum].header) then
        stats.header = "yes"
    elseif langs[lnum].longOpen and string.match(line, langs[lnum].longOpen) and string.match(line, langs[lnum].longEnd) then
        stats.ccount = stats.ccount + 1
    elseif langs[lnum].longOpen and string.match(line, langs[lnum].longOpen) then
        longComment = true
        stats.ccount = stats.ccount + 1
    elseif langs[lnum].xomment  and string.match(line, langs[lnum].xomment) then
        stats.xcount = stats.xcount + 1
    elseif langs[lnum].comment  and string.match(line, langs[lnum].comment) then
        stats.ccount = stats.ccount + 1
    elseif string.match(line, "^%s-$") then
        stats.ecount = stats.ecount + 1
    else
        stats.lcount = stats.lcount + 1
    end
end
stats.tcount = stats.ccount + stats.lcount + stats.ecount
stats.cperc = round(( stats.ccount * 100 ) / stats.tcount)
stats.eperc = round(( stats.ecount * 100 ) / stats.tcount)
stats.xperc = round(( stats.xcount * 100 ) / stats.tcount)
stats.lperc = round(100 - ( stats.cperc + stats.eperc + stats.xperc))
stats.tperc = round(stats.lperc + stats.eperc + stats.cperc + stats.xperc)
stats.size  = getSize(f)
stats.print()
-- }}}
-- EOF
