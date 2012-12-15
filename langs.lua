#!/usr/bin/env lua
-- langs.lua - language config file for codestats.lua
-- Copyright Stæld Lakorv, 2010 <staeld@staeld.co.cc>
-- Released under GPLv3+
sHeader = "#%!%/[%w%s/_%.]+"
langs = {
    {
        name    = "lua",
        ending  = "lua",
        comment = "^%s-%-%-",
        longOpen= "%-%-%[%[",
        longEnd = "%-%-%]%]",
        header  = sHeader .. "lua"
    },
    {
        name    = "bash",
        ending  = "sh",
        comment = "#",
        header  = sHeader .. "bash"
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
        xomment = "^%s-'''",
        comment = "^%s-'"
    },
    {
        name    = "perl",
        ending  = "p[lm]",
        comment = "#",
        longOpen= "^=",
        longEnd = "^=cut",
        header  = sHeader .. "perl"
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
        longOpen= "^%s-<!%-%-",
        longEnd = "%-%->",
        header  = "^%s-<!DOCTYPE%s+HTML"
    },
    {
        name    = "xhtml",
        ending  = "x?html?",
        longOpen= "^%s-<!%-%-",
        longEnd = "%-%->",
        header  = "%s-<!DOCTYPE%s+html"
    },
    {
        name    = "ruby",
        ending  = "rb",
        comment = "#",
        header  = sHeader .. "ruby"
    },
    {
        name    = "io",
        ending  = "io",
        comment = "%/%/",
        xomment = "#",
        longOpen= "/%*",
        longEnd = "%*/",
        header  = sHeader .. "io"
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
        comment = "#",              -- Here, comment means header, any level
        xomment = "[=-][=-][=-]"    -- And xomment is other type of header (conflicts w/hr-line)
    },
}
