#!/usr/bin/env python3

# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2024 Nathan McCamish

# -*- coding: utf-8 -*-

import os
import puz  # puzpy
import sys

if len(sys.argv) > 2:
    print(f"Usage: {sys.argv[0]} [path]")

    sys.exit(1)

dir = sys.argv[1] if len(sys.argv) == 2 else '.'

if not os.path.isdir(dir):
    print(f"{dir} is not a directory!")

    sys.exit(1)

for path in os.listdir(dir):
    path = os.path.join(dir, path)

    if os.path.isdir(path):
        continue

    try:
        puzzle = puz.read(path)
    except:
        continue

    assert len(puzzle.fill) == len(puzzle.solution)

    count = sum(1 for a, b in zip(puzzle.fill, puzzle.solution) if a != b)
    black_square = puzzle.blacksquare()
    black_squares = sum(1 for s in puzzle.solution if s == black_square)
    white_squares = len(puzzle.fill) - black_squares
    completion_rate = (white_squares - count) / white_squares

    print(f"{path} ({completion_rate:.0%})")
