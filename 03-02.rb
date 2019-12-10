#!/usr/bin/env ruby
# frozen_string_literal: true

input = IO.read('03.input').split("\n")

paths = input.map do |wire|
  wire.split(',').each_with_object([[0, 0]]) do |ins, p|
    dir = ins[0]
    mag = ins[1..-1].to_i

    mag.times do |_i|
      last_x, last_y = p[-1]

      p.<< case dir
           when 'R'
             [last_x + 1, last_y]
           when 'L'
             [last_x - 1, last_y]
           when 'U'
             [last_x, last_y + 1]
           when 'D'
             [last_x, last_y - 1]
           end
    end
  end
end

intersections = (paths[0] & paths[1])[1..-1]
puts intersections.map { |p| paths[0].index(p) + paths[1].index(p) }.min
