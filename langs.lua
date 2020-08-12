#!/usr/bin/env lua
-- langs.lua - language config file for codestats.lua
-- Copyright Stæld Lakorv, 2010 <staeld@illumine.ch>
-- Released under the GNU GPLv3+
script_header = "#!/[%w%s/_%.]+"
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
        comment = "^%s*#",
        header  = script_header .. "bash"
    },
    {
        name    = "cpp",
        ending  = "cpp",
        comment = "^%s*//",
        longOpen= "/%*",
        longEnd = "%*/"
    },
    {
        name    = "c",
        ending  = "c",
        comment = "^%s*//",
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
        comment = "^%s*#",
        longOpen= "^=",
        longEnd = "^=cut",
        header  = script_header .. "perl"
    },
    {
        name    = "php",
        ending  = "php",
        comment = "^%s*//",
        xomment = "^%s*#",
        longOpen= "/%*",
        longEnd = "%*/"
    },
    {
        name    = "html",
        ending  = "html?",
        comment = "^%s*<!%-%-.-%-%->",
        longOpen= "<!%-%-",
        longEnd = "%-%->",
        header  = "^%s*<!DOCTYPE%s+[Hh][Tt][Mm][Ll]"
    },
    {
        name    = "xhtml",
        ending  = "x?html?",
        comment = "^%s*<!%-%-.-%-%->",
        longOpen= "<!%-%-",
        longEnd = "%-%->",
        header  = "^%s*<!DOCTYPE.*XHTML"
    },
    {
        name    = "css",
        ending  = "css",
        comment = "^%s*/%*.-%*/",
        longOpen= "/%*",
        longEnd = "%*/"
    },
    {
        name    = "ruby",
        ending  = "rb",
        comment = "^%s*#",
        header  = script_header .. "ruby"
    },
    {
        name    = "io",
        ending  = "io",
        comment = "^%s*//",
        xomment = "^%s*#",
        longOpen= "/%*",
        longEnd = "%*/",
        header  = script_header .. "io"
    },
    {
        name    = "lolcode",
        ending  = "lol",
        comment = "^%s*BTW",
        longOpen= "OBTW",
        longEnd = "TLDR",
        header  = "HAI"
    },
    {
        name    = "markdown",
        ending  = "mk?d",
        comment = "^#",             -- Here, comment means header, any level
        xomment = "^[=-][=-][=-]+$" -- xomment is other type of header (NOTE: conflicts w/hr-line)
    },
    {
        name    = "python",
        ending  = "py",
        comment = "^%s*#",
        -- Unfortunately, Python uses the same syntax for multi-line quotes and strings, so no simple distinction can be made here
        header  = script_header .. "python"
    },
}
