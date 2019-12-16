#!/usr/bin/env ruby
# frozen_string_literal: true

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
   K)L
   K)YOU
   I)SAN'

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

  def trace_path(node, path = [])
    orbits = parent(node)

    return path if orbits.nil?

    trace_path(orbits, path.<<(orbits))
  end

  def hops_between(first, second)
    p1 = trace_path(first)
    p2 = trace_path(second)

    common = (p1 & p2).first
    (p1.index(common) + p2.index(common))
  end
end

Test = Advent.new(test_input)

raise unless Test.hops_between('YOU', 'SAN') == 4

input = IO.read('06.input')

Real = Advent.new(input)

puts Real.hops_between('YOU', 'SAN')
