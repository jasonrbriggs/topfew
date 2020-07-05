import os
import sequtils
import streams
import strutils
import tables

import docopt

let doc = """
Topfew.

Usage:
  tf [--fields=<fields>] [--few=<few>] <filename>

Options:
  --fields=<fields>   Which fields to select [default: 1]
  --few=<few>         How many results to display [default: 10]
"""


proc findKey(s: string, start: int, occ: int, actualOcc: int): (int, string) =
    let found = find(s, ' ', start)
    if found < 1:
        return (-1, "")
    if actualOcc + 1 == occ:
        return (found, s[start..found])
    return findKey(s, found + 1, occ, actualOcc + 1)


when isMainModule:
    let args = docopt(doc, version = "Topfew 0.1")

    let fieldsArg = split($args["--fields"], ',')
    var fields: seq[int] = @[]
    for x in fieldsArg:
        add(fields, parseInt(x))
    let few = parseInt($args["--few"])
    let filename = $args["<filename>"]

    if not fileExists(filename):
        echo "Page " & filename & " does not exist"
        quit 1

    var lines: seq[seq[string]] = @[]
    var strm = newFileStream(filename, fmRead)
    var line = ""
    var keys = initCountTable[string]()
    while strm.readLine(line):
        var key = ""
        var tok = ""
        var count = 0
        var pos = 0
        var lastField = 0
        for field in fields:
            (pos, tok) = findKey(line, pos, field, lastField)
            lastField = field
            if pos < 1:
                raise newException(ValueError, "Field " & field.`$` & " not found")
            key = key & tok
        inc(keys, key)
    sort(keys)
    var count = 0
    for k,v in pairs(keys):
        echo v.`$` & " " & k
        count = count + 1
        if count >= few:
            break