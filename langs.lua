#!/usr/bin/env lua
-- langs.lua - language config file for codestats.lua
-- Copyright Stæld Lakorv, 2010 <staeld@illumine.ch>
-- Released under GPLv3+
script_header = "#%!%/[%w%s/_%.]+"
langs = {
    {
        name    = "lua",
        ending  = "lua",
        comment = "^%s-%-%-",
        longOpen= "%-%-%[%[",
        longEnd = "%-%-%]%]",
        header  = script_header .. "lua"
    },
    {
        name    = "bash",
        ending  = "sh",
        comment = "#",
        header  = script_header .. "bash"
    },
    {
        name    = "cpp",
        ending  = "cpp",
        comment = "%/%/",
        longOpen= "/%*",
        longEnd = "%*/"
    },
    {
        name    = "c",
        ending  = "c",
        comment = "%/%/",
        longOpen= "/%*",
        longEnd = "%*/"
    },
    {
        name    = "vbnet",
        ending  = "vb",
        comment = "^%s-'",
        xomment = "^%s-'''"
    },
    {
        name    = "perl",
        ending  = "p[lm]",
        comment = "#",
        longOpen= "^=",
        longEnd = "^=cut",
        header  = script_header .. "perl"
    },
    {
        name    = "php",
        ending  = "php",
        comment = "%/%/",
        xomment = "#",
        longOpen= "/%*",
        longEnd = "%*/"
    },
    {
        name    = "html",
        ending  = "html?",
        comment = "^%s-<!%-%-.-%-%->",
        longOpen= "^%s-<!%-%-",
        longEnd = "%-%->",
        header  = "^%s-<!DOCTYPE%s+[Hh][Tt][Mm][Ll]"
    },
    {
        name    = "xhtml",
        ending  = "x?html?",
        comment = "^%s-<!%-%-.-%-%->",
        longOpen= "^%s-<!%-%-",
        longEnd = "%-%->",
        header  = "%s-<!DOCTYPE%s+html"
    },
    {
        name    = "css",
        ending  = "css",
        comment = "^%s-/%*.-%*/",
        longOpen= "/%*",
        longEnd = "%*/"
    },
    {
        name    = "ruby",
        ending  = "rb",
        comment = "#",
        header  = script_header .. "ruby"
    },
    {
        name    = "io",
        ending  = "io",
        comment = "%/%/",
        xomment = "#",
        longOpen= "/%*",
        longEnd = "%*/",
        header  = script_header .. "io"
    },
    {
        name    = "lolcode",
        ending  = "lol",
        comment = "BTW",
        longOpen= "OBTW",
        longEnd = "TLDR",
        header  = "HAI"
    },
    {
        name    = "markdown",
        ending  = "mk?d",
        comment = "^#",              -- Here, comment means header, any level
        xomment = "^[=-][=-][=-]+$"    -- And xomment is other type of header (NOTE: conflicts w/hr-line)
    },
}
