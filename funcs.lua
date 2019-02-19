-- funcs.lua - Functions library for codestats.lua
-- Copyright Stæld Lakorv, 2012-2013 <staeld@illumine.ch>

function flags.activate(flag)   -- Call the function of a --flag
    flags[flag]()
end

function balancePrint(t, stat)  -- Print out with right-alignment
    print(t .. string.rep(" ", offset - ( t:len() + stat:len() )) .. stat)
end

function stats.percent(t) -- Calculate various percentages from a code stats table
    t.cperc = round(( t.ccount * 100 ) / t.tcount)  -- Comments
    t.eperc = round(( t.ecount * 100 ) / t.tcount)  -- Empty
    t.xperc = round(( t.xcount * 100 ) / t.tcount)  -- Extra comments
    t.lperc = round(100 - ( t.cperc + t.eperc + t.xperc)) -- Code
    t.tperc = round(t.lperc + t.eperc + t.cperc + t.xperc)
    return t
end
function stats.print(inFile, issummary)
    local s
    if not issummary then
        s = {
            { name = "File", data = inFile },
            { name = "Size", data = stats[inFile].size },
            { name = "Language", data = flang.name }
        }
        if flang.header then
            table.insert(s, { name = "Header", data = stats[inFile].header })
        end
        for _, stat in ipairs(s) do
            balancePrint(stat.name .. " ", stat.data)
        end
        print()
        -- Show author/licence information
        if verbose then
            if stats[inFile].copyright then
                local c = { "Author", "Email", "Year" }
                for _, field in ipairs(c) do
                    balancePrint(field, stats[inFile].copyright[field:lower()])
                end
            end
            if stats[inFile].licence then
                if stats[inFile].version then stats[inFile].version = " " .. stats[inFile].version else stats[inFile].version = "" end
                balancePrint("Licence", stats[inFile].licence .. stats[inFile].version)
            end
            if stats[inFile].copyright or stats[inFile].licence then print() end
        end
    end
    if issummary then balancePrint("Total size ", stats[inFile].size) end -- Since it's not covered above
    local d = {
        { name = "Code",    code = "l" },
        { name = "Comment", code = "c" },
        { name = "Empty",   code = "e" },
        { name = "Total",   code = "t" }
    }
    if flang.xomment then
        table.insert(d, 3, { name = "Comment #2", code = "x" })
    end
    for _, data in ipairs(d) do
        local count = data.code .. "count"
        local perc  = data.code .. "perc"
        local stat  = stats[inFile][count] .. " (" .. string.rep(" ", 6 - string.len(stats[inFile][perc])) .. stats[inFile][perc] .. " % )"
        balancePrint(data.name, stat)
    end
end
function round(n)
    n = string.format("%.1f", n)
    return n
end
function getSize(f)
    local bytes, size, unit
    if not ( type(f) == "userdata" ) then
        bytes = f -- Assume f is actually a byte size
    else
        bytes = f:seek("end")
    end
    if bytes >= 1048576 then
        size = bytes / 1048576
        unit = "MiB"
    elseif bytes >= 1024 then
        size = bytes / 1024
        unit = "kiB"
    else
        size = bytes
        unit = "B"
    end
    size = string.format("%.1f " .. unit, size)
    return size, bytes
end
function getAuthor(line)
    local copyright = line:lower():find("copyright") or line:find("%s%([Cc]%)%s") or line:find("%S+@%S+%.%S+") or line:find("auth[o:]")
    if copyright then
        copyright = {}
        copyright.year = line:match("(%d%d%d%d%-?%d?%d?%d?%d?)") or line:match("%([Cc]%)%s+(%d%d%d%d)")
        copyright.author = line:match("[Rr][Ii][Gg][Hh][Tt][Ss]?%s+([^,%d]+)[%s,]+%d?") or line:match("[Rr][Ee][Tt]+%s+([^,]+)[%s,]+%d?") or line:match("%([Cc]%)%s+%d+[,%s]+([^%,]+)%.?$")
        copyright.email  = line:match("([^%s<%(]+@%S+%.[^%s>%)]+)")
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
    if licence == "Creative Commons" then -- TODO: Really should move this somewhere else and make it scalable
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
function initTotalStats()
    stats._total = {}
    for _, s in ipairs({"tcount", "ccount", "ecount", "xcount", "lcount", "bytes"}) do
        stats._total[s] = 0
    end
end
