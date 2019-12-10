#!/usr/bin/env ruby
# frozen_string_literal: true

# Fuel required to launch a given module is based on its mass. Specifically,
# to find the fuel required for a module, take its mass, divide by three,
# round down, and subtract 2
#
def fuel_required(mass)
  (mass / 3.0).floor - 2
end

fail unless fuel_required(12) == 2
fail unless fuel_required(14) == 2
fail unless fuel_required(1969) == 654
fail unless fuel_required(100756) == 33583

input = IO.read('01.input').split("\n")

puts input.map { |n| fuel_required(n.to_i) }.sum
