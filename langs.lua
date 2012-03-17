#!/usr/bin/env lua
-- langs.lua - language config file for codestats.lua
-- Copyright Stæld Lakorv, 2010 <staeld@staeld.co.cc>
-- Released under GPLv3+
sHeader = "^#%!%/[%w%s/_%.]+"
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
        comment = "^%s-#",
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
        comment = "^%s-#",
       longOpen= "^=",
       longEnd="^=cut",
        header  = sHeader .. "perl"
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
        name    = "html",
        ending  = "html?",
        longOpen= "^%s-%<%!%-%-",
        longEnd = "%-%-%>",
        header  = "^%s-%<%!DOCTYPE%s+HTML"
    },
    {
        name    = "xhtml",
        ending  = "x?html?",
        longOpen= "^%s-%<%!%-%-",
        longEnd = "%-%-%>",
        header  = "^%s-%<%!DOCTYPE%s+html"
    },
    {
        name    = "ruby",
        ending  = "rb",
        comment = "^%s-#",
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
        comment = "^%s-BTW",
        longOpen= "OBTW",
        longEnd = "TLDR",
        header  = "HAI"
    },
}
