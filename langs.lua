#!/usr/bin/env lua
-- langs.lua - language config file for codestats.lua
-- Copyright Stæld Lakorv, 2010 <staeld@staeld.co.cc>
-- Released under GPLv3+
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
        name    = "perl",
        ending  = "pl",
        comment = "^%s-#",
        header  = "^#%!/[%w%s/_%.]+perl.*"
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
