#!/usr/bin/env python3

import csv

ratings_data = {}
game_data = {}

r = open('ratings.csv', 'r')
rr = csv.reader(r)
h = next(rr)[1:]

for row in rr:
  ratings_data[row[0]] = { key: int(value) for key, value in zip(h, row[1:]) }

#print(ratings_data["NE"]["PassOff"])

# process game results and build a file that we can produce updated ratings from

g = open('games.csv', 'r')
gr = csv.reader(g)
gh = next(gr)[1:]

for row in gr:
