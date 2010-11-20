#!/usr/bin/env lua
-- codestats.lua 1.1.4 - analyze source code
-- Copyright Stæld Lakorv, 2010 <staeld@staeld.co.cc>
-- Released under GPLv3+
--[[
    TODO:
        INFO FETCHING (LICENCE, ETC)
        CLEAN UP THIS MESS OF A FILE
            MAKE LEGIBLE
            FIX SOME MORE CODE
--]]
-- {{{ Init
langs = {
    {
        name    = "lua",
        ending  = "lua",
        comment = "^%s-%-%-",
        longOpen= "%-%-%[%[",
        longEnd = "%-%-%]%]",
        header  = "^#%!/[%w%s/_%.]+lua.*"
    },
    {
        name    = "bash",
        ending  = "sh",
        comment = "^%s-#",
        header  = "^#%!/bin/bash"
    },
    {
        name    = "c",
        ending  = "c",
        comment = "%/%/",
        longOpen= "/%*",
        longEnd = "%*/"
    },
    {
        name    = "cpp",
        ending  = "cpp",
        comment = "%/%/",
        longOpen= "/%*",
        longEnd = "%*/"
    },
    {
        name    = "vb.net",
        ending  = "vb",
        xomment = "^%s-'''",
        comment = "^%s-'"
    },
    {
        name    = "php",
        ending  = "php",
        comment = "%/%/",
        xomment = "^%s-#",
        longOpen= "/%*",
        longEnd = "%*/"
    },
    {
        name    = "io",
        ending  = "io",
        comment = "%/%/",
        xomment = "#",
        longOpen= "/%*",
        longEnd = "%*/",
        header  = "#%!/[%w%s/_%.]+io.*"
    },
    {
        name    = "lolcode",
        ending  = "lol",
        comment = "^%s-BTW",
        longOpen= "OBTW",
        longEnd = "TLDR"
    },
}
for i = 1, #langs do
    if not langs.list then
        langs.list = langs[i].name
    else
        langs.list = langs.list .. " " .. langs[i].name
    end
end
io.input(arg[0]) -- read version and usage
for i = 1, 2 do
     name = io.read()
end
io.input():close()
name = string.gsub(name, "^%-%-%s+", "")
msg = {
    noarg = "invalid arguments given. See --help for more info.",
    nofile= "cannot open file ",
    help  = name .. "\
Usage: " .. arg[0] .. [[ [FLAG] [FILE]

Valid flags:  --LANG  analyze source code using parsing options for LANG
 ]] .. [[             --help  this help message

Valid options for LANG: ]] .. langs.list
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
function err(m, f)
    if not f then f = "" end
    print("error: " .. m .. f)
    os.exit(1)
end
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
        balancePrint(30, s[i].name, s[i].data)
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
function getSize()
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
    print(msg.help)
    os.exit()
end
for i = 1, #langs do
    if string.match(arg[1], "%." .. langs[i].ending .. "$") then
        lnum = i
        argAcpt = true
        inFile = arg[1]
    end
end
if ( argAcpt ~= true ) then
    i = 0
    repeat
        i = i + 1
        if ( arg[1] == "--" .. langs[i].name ) then
            lnum = i
            argAcpt = true
            inFile = arg[2]
        end
    until ( argAcpt == true ) or ( i == #langs )
end
if ( argAcpt ~= true ) or not inFile then
    err(msg.noarg)
end
if not io.open(inFile, "r") then
    err(msg.nofile, inFile)
end
-- }}}

-- {{{ Analyze
f = io.open(inFile, "r")
for line in f:lines() do
    if ( longComment == true ) then
        stats.ccount = stats.ccount + 1
        if string.match(line, langs[lnum].longEnd) then
            longComment = false
        end
    elseif langs[lnum].header and ( stats.lcount == 0 ) and string.match(line, langs[lnum].header) then
        stats.header = "yes"
    elseif langs[lnum].longOpen and string.match(line, langs[lnum].longOpen) and string.match(line, langs[lnum].longEnd) then
        stats.ccount = stats.ccount + 1
    elseif langs[lnum].longOpen and string.match(line, langs[lnum].longOpen) then
        longComment = true
        stats.ccount = stats.ccount + 1
    elseif langs[lnum].xomment and string.match(line, langs[lnum].xomment) then
        stats.xcount = stats.xcount + 1
    elseif string.match(line, langs[lnum].comment) then
        stats.ccount = stats.ccount + 1
    elseif not string.match(line, "%S") then
        stats.ecount = stats.ecount + 1
    else
        stats.lcount = stats.lcount + 1
    end
end
stats.tcount = stats.ccount + stats.lcount + stats.ecount
stats.cperc = round(( stats.ccount * 100 ) / stats.tcount)
stats.eperc = round(( stats.ecount * 100 ) / stats.tcount)
stats.xperc = round(( stats.xcount * 100 ) / stats.tcount)
stats.lperc = round(100 - ( stats.cperc + stats.eperc ))
stats.tperc = round(stats.lperc + stats.eperc + stats.cperc + stats.xperc)
stats.size  = getSize()
stats.print()
-- }}}
-- EOF
