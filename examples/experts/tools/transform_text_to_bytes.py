#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
AUTHOR Krusty/Benediction

Transform an ascii text to the byte where the value corresponds to the position
in the font


Usage:

    cat texte | python transform_text_to_bytes corresp.txt > texte.bin
"""


import sys


INFILE = sys.stdin
OUTFILE = sys.stdout

# Read correspondance file
fcorr = open(sys.argv[1])
corres = []
for line in fcorr.readlines():
    if line[0] == '#':
        continue

    corres.append(line[0])

# Build the transition
positions = []
for line in INFILE:
    for character in line[:-1]:
        if character in corres:
            positions.append(corres.index(character))
        else:
            positions.append(0)
            sys.stderr.write('Unknown %c\n' %character)
translation = "".join(['%c' % val for val in positions])

sys.stdout.write(translation)

