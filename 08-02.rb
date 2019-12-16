#!/usr/bin/env ruby
# frozen_string_literal: true

WIDTH = 25
HEIGHT = 6

# @return [Array[Int]]
def image_to_layers(raw, x, y)
  regex = Regexp.new("\\d{#{x * y}}")
  raw.scan(regex)
end

input = IO.read('08.input')
layers = image_to_layers(input, WIDTH, HEIGHT).map(&:chars)

# Rotate the "image" anticlockwise, and select the first non-transparent pixel
# on each "row".
#
combined = layers.transpose.reverse.map do |layer|
  layer.find { |p_val| p_val != '2' }
end

# I'm reversing the colours because I use a dark-on-light terminal.
#
combined.reverse.each_slice(WIDTH) do |row|
  puts row.join.gsub(/1/, "\u2588").gsub(/0/, ' ')
end
