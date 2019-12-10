#!/usr/bin/env ruby

test_input =
  'COM)B
   B)C
   C)D
   D)E
   E)F
   B)G
   G)H
   D)I
   E)J
   J)K
   K)L'

class Advent
  def initialize(input)
    @tree = orbit_tree(input)
  end

  def sum_of_all_paths
    @tree.keys.map { |v| trace_path(v) }.sum
  end

  # returns nil for the root node
  #
  def parent(node)
    @tree[node]
  end

  def orbit_tree(input)
    input.split.each_with_object({}) do |l, aggr|
      parent, id = l.split(')')
      aggr[id] = parent
    end
  end

  def trace_path(node, hops = 0)
    orbits = parent(node)

    return hops if orbits.nil?

    trace_path(orbits, hops + 1)
  end
end

Test = Advent.new(test_input)

fail unless Test.trace_path('D') == 3
fail unless Test.trace_path('L') == 7
fail unless Test.sum_of_all_paths == 42

input = IO.read('06.input')

Real = Advent.new(input)

puts Real.sum_of_all_paths

