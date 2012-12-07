-- funcs.lua - Functions library for codestats.lua
-- Copyright Stæld Lakorv, 2012 <staeld@illumine.ch>

function flags.activate(flag)
    flags[flag]()
end

function balancePrint(t, stat)
    print(t .. string.rep(" ", offset - ( t:len() + stat:len() )) .. stat)
end

function stats.print()
    local s = {
        { name = "File", data = inFile },
        { name = "Size", data = stats.size },
        { name = "Language", data = flang.name }
    }
    if flang.header then
        table.insert(s, { name = "Header", data = stats.header })
    end
    for _, stat in ipairs(s) do
        balancePrint(stat.name .. " ", stat.data)
    end
    print()
    local d = {
        { name = "Code",    count = "lcount", perc = "lperc" },
        { name = "Comment", count = "ccount", perc = "cperc" },
        { name = "Empty",   count = "ecount", perc = "eperc" },
        { name = "Total",   count = "tcount", perc = "tperc" }
    }
    if flang.xomment then
        table.insert(d, 3, { name = "Comment #2", count = "xcount", perc = "xperc" })
    end
    for _, data in ipairs(d) do
        local stat = stats[data.count] .. " (" .. string.rep(" ", 6 - string.len(stats[data.perc])) .. stats[data.perc] .. " % )"
        balancePrint(data.name, stat)
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
    if l >= 1048576 then
        l = l / 1048576
        unit = "MiB"
    elseif l >= 1024 then
        l = l / 1024
        unit = "kiB"
    else
        unit = "B"
    end
    l = string.format("%.1f " .. unit, l)
    return l
end
function getAuthor(line)
    local copyright = line:lower():find("copyright") or line:find("%S+@%S+%.%S+") or line:find("auth[o:]")
    if copyright then
        copyright = {}
        copyright.year = line:match("(%d%d%d%d%-?%d?%d?%d?%d?)")
        copyright.author = line:match("[Rr][Ii][Gg][Hh][Tt]%s+(.+),")
        copyright.email  = line:match("([^%s<]+@%S+%.[^%s>]+)")
    end
    return copyright
end
function getLicence(line)
    for i, l in ipairs(licences) do
        if line:lower():match(l.name) then
            licence = l.name
            break
        end
        for j, m in ipairs(l.matches) do
            if line:lower():match(m) then
                licence = l.name
                break
            end
        end
    end
    if licence == "Creative Commons" then
        local variant = ""
        local variants = { "nc", "nd", "sa", "by" }
        for _, word in ipairs(variants) do
            if line:lower():match("(%-" .. word .. ")[%s-]") then
                variant = variant .. word
            end
        end
        variant = variant:gsub("^%-", "")
    end
    return licence, variant
end
function getLicenceVersion(line)
    local matches = { "version ", "v" }
    for _, word in ipairs(matches) do
        local version = line:match(word .. "([%d%.]+)")
        if version then return version end
    end
    if not version then return nil end
end
