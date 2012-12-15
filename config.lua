-- config.lua - Various configuration and variables for codestats.lua
-- Copyright Stæld Lakorv, 2012 <staeld@illumine.ch>

-- Width to use when printing right-aligned figures
offset = 30
-- Supported flags for execution
flags = {
    verbose = function() verbose = true end,
}
licences = {
    { name = "GNU GPL",          matches = { "gpl", "general public licen[cs]e" } },
    { name = "GNU LGPL",         matches = { "lgpl", "lesser public licen[cs]e" } },
    { name = "GNU AGPL",         matches = { "agpl", "affero general public licen[cs]e" } },
    { name = "GNU FDL",          matches = { "fdl", "free documentation licen[cs]e" } },
    { name = "Creative Commons", matches = { "cc%-nd", "cc%-nc", "cc%-sa", "cc%-by" } },
    { name = "Public domain",    matches = { "public domain" } },
    { name = "Apache License",   matches = { "apache licen[cs]e" } },
    { name = "Common Public License", matches = { "cpl" } },
}

