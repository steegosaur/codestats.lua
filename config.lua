-- config.lua - Various configuration and variables for codestats.lua
-- Copyright Stæld Lakorv, 2012 <staeld@illumine.ch>

-- Width to use when printing right-aligned figures
offset = 40
-- Supported flags for execution
flags = {
    verbose = function() verbose = true end,
    summary = function() dosummary = true; initTotalStats() end,
    sumonly = function() dosumonly = true; initTotalStats() end,
}
msg = {
    noarg  = "invalid arguments given. See --help for more info.",
    nofile = "cannot open file ",
    lFound = "language recognised by means of ", -- for debug purposes
    help   = function()
        print(name)
        print("Usage: " .. arg[0] .. " [FLAG] [FILE] [FLAG] [FILE2] […]\n")
        print("Valid flags: --LANG      analyze source code parsing it as LANG")
        print("                         (note: valid until overridden by new flag")
        print("             --verbose   print author and licence information if found")
        print("             --summary   print summary stats of all files")
        print("             --sumonly   print only the total summary")
        print("             --help      show this help message\n")
        print("Valid LANGs: " .. langs.list)
    end
}
licences = {
    { name = "GNU GPL",          matches = { "gpl", "general public licen[cs]e" } },
    { name = "GNU LGPL",         matches = { "lgpl", "lesser public licen[cs]e" } },
    { name = "GNU AGPL",         matches = { "agpl", "affero general public licen[cs]e" } },
    { name = "GNU FDL",          matches = { "fdl", "free documentation licen[cs]e" } },
    { name = "Creative Commons", matches = { "cc%-nd", "cc%-nc", "cc%-sa", "cc%-by", "cc%s?0" } },
    { name = "Public domain",    matches = { "public domain" } },
    { name = "Apache License",   matches = { "apache licen[cs]e" } },
    { name = "Common Public License", matches = { "cpl" } },
    { name = "BSD License",      matches = { "redistribution and use in source and binary" } },
}

