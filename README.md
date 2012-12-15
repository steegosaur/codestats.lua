Readme for codestats.lua
========================

`codestats.lua` is a lua script for analyzing plaintext source code of various 
languages. It currently is in a rather simple form, and consists of the main 
script file and a configuration file for the language information. More 
advanced algorithms for language recognisation, line counting, and so on may be
coming. More statistics will also be added by time.

The only requirement for running `codestats.lua` is merely a Lua 5.1-compliant 
interpreter. No external calls are made (files are handled with lua's 
built-in functions), and the script *should* therefore be platform independent. 
It has however not been tested on other platforms than GNU/Linux.

The functions of `codestats.lua` are rudimentary. The syntax is simple:

    ./codestats.lua file.ext

`codestats.lua` will try to understand what language the file is written in,
by first checking whether it contains a recognised file header or (if no
header) by looking at its extension. If it does not understand the extension,
you may run it with a language flag to force it, like

    ./codestats.lua --perl somefile

Note that using the wrong language option may result in undesirable results. 
Use at own risk. 

For a list of the currently enabled languages, use

    ./codestats.lua --help

Depending on the language of the file analyzed, the output may present various 
information. The currently implemented information includes:

    File        filename
    Size        size in B, kiB, or MiB (controlled by getSize())
    Language    language of the file (as reported; not necessarily correct)
    Header      if an interpreted language: does code have #! header?
    Code        amount of non-comment and non-empty lines
    Comment     amount of lines matching the comment pattern(s)
    Comment #2  if a second kind of comments exist; see Comment above
    Empty       amount of empty lines (or containing only whitespace)
    Total       total amount of lines parsed, excluding the eventual header

In addition, the following may be extracted with the `--verbose` flag if found
found in a supported format:

    Author      name of the author
    Email       email address of author
    Year        year of creation/copyright
    Licence     specified licence of software

Yes, this is a hacked-together solution. No, it should *not* be used for
anything important.
