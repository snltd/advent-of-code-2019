#!/usr/bin/env ruby
# frozen_string_literal: true

lower = 128_392
upper = 643_281

candidates = lower.upto(upper).map(&:to_s)

puts candidates.reject { |n| n.squeeze == n }.select do |n|
  a = n.split('')
  a.sort == a
end.size
