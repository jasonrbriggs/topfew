#! /usr/bin/env python3

"""
Topfew.

Usage:
  tf [--fields=<fields>] [--few=<few>] <filename>

Options:
  --fields=<fields>   Which fields to select [default: 1]
  --few=<few>         How many results to display [default: 10]
"""

from docopt import docopt


args = docopt(__doc__, version="0.1")

fields = [int(x) for x in args["--fields"].split(',')]
few = int(args["--few"])
filename = args["<filename>"]

keys = {}
with open(filename) as f:
    for line in f.readlines():
        key = ""
        tokens = line.split(' ')
        for field in fields:
            key = key + tokens[field-1]
        if key not in keys:
            keys[key] = 1
        else:
            keys[key] = keys[key] +1

count = 0
for k,v in {k: v for k, v in sorted(keys.items(), key=lambda item: item[1], reverse=True)}.items():
    print(v, k)
    count += 1
    if count >= few:
        break
