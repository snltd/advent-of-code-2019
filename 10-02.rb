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

def distance(a, b)
  (Math.sqrt((b[0] - a[0]) ** 2 + (b[1] - a[1]) ** 2)).floor(13)
end

# Calculate the angle from the +ve y axis to all asteroids, make a unique
# list, and the size of that list is the asteroids you can see

def all_views(input)
  asteroid_positions(input).map do |p1|
    asteroid_positions(input).map { |p2| angle(p1, p2) }.compact.uniq.size
  end
end

def hit_list(input, base_pos)
  asteroids_by_angle = asteroid_positions(input).map do |p2|
    [p2, angle(base_pos, p2), distance(base_pos, p2)]
  end.reject { |a| a[0] == base_pos }.sort_by { |a| a[1] }.reverse

  angles = asteroids_by_angle.map { |a| a[1] }.uniq

  ret = []

  loop do
    angles.each do |ang|
      target = asteroids_by_angle.select do |ast|
        ast[1] == ang
      end.sort_by { |a| a[2] }.first

      next if target.nil?

      ret.<< target[0]
      asteroids_by_angle.delete(target)
    end

    break if asteroids_by_angle.empty?
  end

  ret
end

test_input = '.#..##.###...#######
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
###.##.####.##.#..##'

test_base_pos = [11, 13]

test_hit = hit_list(test_input, test_base_pos)
raise unless test_hit[0] == [11,12]
raise unless test_hit[1] == [12,1]
raise unless test_hit[2] == [ 12,2]
raise unless test_hit[9] == [ 12,8]
raise unless test_hit[19] == [ 16,0]
raise unless test_hit[49] == [ 16,9]
raise unless test_hit[99] == [ 10,16]
raise unless test_hit[198] == [ 9,6]
raise unless test_hit[199] == [ 8,2]
raise unless test_hit[200] == [ 10,9]
raise unless test_hit[298] == [11, 1]
raise unless test_hit.last == [11, 1]

input = IO.read('10.input')

target_200 = hit_list(input, [30, 34])[199]

puts target_200[0] * 100 + target_200[1]
