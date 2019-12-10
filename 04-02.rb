#!/usr/bin/env ruby
# frozen_string_literal: true

lower = 128_392
upper = 643_281

candidates = lower.upto(upper).map(&:to_s)

def still_okay?(num_arr)
  counts = num_arr.each_with_object(Hash.new(0)) do |e, sum|
    sum[e] += 1
  end

  counts.values.include?(2)
end

puts candidates.reject { |n| n.squeeze == n }.select do |n|
  a = n.split('')
  a.sort == a && still_okay?(a)
end.count
