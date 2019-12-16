#!/usr/bin/env ruby
# frozen_string_literal: true

# @return [Array[Int]]
def image_to_layers(raw, x, y)
  regex = Regexp.new("\\d{#{x * y}}")
  raw.scan(regex)
end

input = IO.read('08.input')

layers = image_to_layers(input, 25, 6)

counts = layers.map do |l|
  l.chars.each_with_object(Hash.new(0)) do |e, sum|
    sum[e] += 1
  end
end

zero_counts = counts.map { |c| [c['0'], c] }
fewest_zeros = zero_counts.min_by { |a, _b| a }[1]
puts fewest_zeros['1'] * fewest_zeros['2']
