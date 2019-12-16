#!/usr/bin/env ruby
# frozen_string_literal: true

def asteroid_positions(input)
  input.split.each_with_object([]).with_index do |(row, aggr), y|
    row.chars.each_with_index { |char, x| aggr.<< [x, y] if char == '#' }
  end
end

def angle(a, b)
  return nil if a == b

  Math.atan2(b[0] - a[0], b[1] - a[1])
end

# Calculate the angle from the +ve y axis to all asteroids, make a unique
# list, and the size of that list is the asteroids you can see

def all_views(input)
  asteroid_positions(input).map do |p1|
    x = asteroid_positions(input).map { |p2| angle(p1, p2) }.compact.uniq.size
    puts "#{p1} #{x}"
    x
  end
end

raise unless all_views('.#..#
.....
#####
....#
...##').max == 8

raise unless all_views('......#.#.
#..#.#....
..#######.
.#.#.###..
.#..#.....
..#....#.#
#..#....#.
.##.#..###
##...#..#.
.#....####').max == 33

raise unless all_views('#.#...#.#.
.###....#.
.#....#...
##.#.#.#.#
....#.#.#.
.##..###.#
..#...##..
..##....##
......#...
.####.###.').max == 35

raise unless all_views('.#..#..###
####.###.#
....###.#.
..###.##.#
##.##.#.#.
....###..#
..#.#..#.#
#..#.#.###
.##...##.#
.....#.#..').max == 41

raise unless all_views('.#..##.###...#######
##.############..##.
.#.######.########.#
.###.#######.####.#.
#####.##.#.##.###.##
..#####..#.#########
####################
#.####....###.#.#.##
##.#################
#####.##.###..####..
..######..##.#######
####.##.####...##..#
.#####..#.######.###
##...#.##########...
#.##########.#######
.####.#.###.###.#.##
....##.##.###..#####
.#.#.###########.###
#.#.#.#####.####.###
###.##.####.##.#..##').max == 210

puts "==="
puts all_views(IO.read('10.input')).max
