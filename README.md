Readme for codestats.lua
========================

`codestats.lua` is a Lua script for analyzing plaintext source code of various 
languages. It is currently in a rather simple form, and consists of the main 
script file and a configuration file for the language information. Note that 
this script is not actively maintained and updates and rewrites are highly 
unlikely.

Note: This script has not undergone much testing at all. There will be bugs.

The only requirement for running `codestats.lua` is a Lua 5.1-compliant 
interpreter. (Update as of 2019-02-19: I am currently running it with Lua 5.3
and have not noticed any abnormalities. YMMV.)

No external calls are made (files are handled with Lua's built-in functions), 
and the script *should* therefore be platform independent. However, it has 
not been tested on other platforms than GNU/Linux.

The functions of `codestats.lua` are rudimentary and the syntax is simple:

    ./codestats.lua file.ext

`codestats.lua` will try to understand what language the file is written in,
by first checking whether it contains a recognised file header or (if no
header) by looking at its extension. If it does not understand the extension,
you may run it with a language flag to force it, like

    ./codestats.lua --perl somefile

Note that the setting stays from the point at where it was set, so all files 
after the flag are treated according to the flag. New flags can be set at any 
point:

    ./codestats.lua --perl somefile.pl --html index.html page2.html

Languages can be specified, added and tweaked by modifying `langs.lua`. For a
list of the currently enabled languages, use

    ./codestats.lua --help

Depending on the language of the file analyzed, the output may present various 
information. The currently implemented information includes:

    File        filename
    Size        size in B, kiB, or MiB (controlled by getSize())
    Language    language of the file (as reported; not necessarily correct!)
    Header      if an interpreted language: does the code have a #! header?
    Code        amount of non-comment and non-empty lines
    Comment     amount of lines matching the comment pattern(s)
    Comment #2  if a second kind of comments exists (see Comment above)
    Empty       amount of empty lines (or containing only whitespace)
    Total       total amount of lines parsed, excluding an eventual header

Single-line comments are counted only if they begin the line (ie. there is no 
code). Multi-line comments are counted from the line they begin on (ie. no 
code is counted on that line).

A total summary is available with the flag `--summary`; if you *only* want the 
summary, you can use `--sumonly`.

In addition, the following may be extracted with the `--verbose` flag if found
in a supported format:

    Author      name of the author
    Email       email address of author
    Year        year of creation/copyright
    Licence     specified licence of software

