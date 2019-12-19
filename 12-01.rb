#!/usr/bin/env ruby

def input_to_pos(input)
  input.split("\n").map { |r| r.scan(/=([\d\-]+)/).map { |p| p[0].to_i } }
end

def pairs
  [[0, 1], [0, 2], [0, 3], [1, 2], [1, 3], [2, 3]]
end

def update_velocity(pos, vel, a, b)
  0.upto(2) do |n|
    if pos[a][n] > pos[b][n]
      vel[a][n] -= 1
      vel[b][n] += 1
    elsif pos[a][n] < pos[b][n]
      vel[a][n] += 1
      vel[b][n] -= 1
    end
  end

  [pos, vel]
end

def apply_gravity(pos, vel)
  pairs.each { |a, b| pos, vel = update_velocity(pos, vel, a, b) }

  [pos, vel]
end

def apply_velocity(pos, vel)
  0.upto(3) { |m| 0.upto(2) { |n| pos[m][n] += vel[m][n] } }

  [pos, vel]
end

def potential_energy(pos)
  pos.map { |m| m.map(&:abs).sum }
end

def kinetic_energy(vel)
  vel.map { |m| m.map(&:abs).sum }
end

def total_energy(pos, vel)
  pe = potential_energy(pos)
  ke = kinetic_energy(vel)

  0.upto(3).map { |n| pe[n] * ke[n] }.sum
end

def energy_of_system(input, iterations)
  pos = input_to_pos(input)
  vel = [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]]

  iterations.times do
    pos, vel = apply_gravity(pos, vel)
    pos, vel = apply_velocity(pos, vel)
  end

  total_energy(pos, vel)
end

fail unless energy_of_system('<x=-1, y=0, z=2>
<x=2, y=-10, z=-7>
<x=4, y=-8, z=8>
<x=3, y=5, z=-1>', 10) == 179

fail unless energy_of_system('<x=-8, y=-10, z=0>
<x=5, y=5, z=10>
<x=2, y=-7, z=3>
<x=9, y=-8, z=-3>', 100) == 1940

puts energy_of_system(IO.read('12.input'), 1000)
