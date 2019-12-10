#!/usr/bin/env ruby
# frozen_string_literal: true

def run_program(prog)
  prog = prog.split(',').map(&:to_i)

  prog.each_slice(4) do |chunk|
    break if chunk[0] == 99

    if chunk[0] == 1
      prog[chunk[3]] = prog[chunk[1]] + prog[chunk[2]]
    elsif chunk[0] == 2
      prog[chunk[3]] = prog[chunk[1]] * prog[chunk[2]]
    end
  end

  prog.join(',')
end

fail unless run_program('1,0,0,0,99') == '2,0,0,0,99'
fail unless run_program('2,3,0,3,99') == '2,3,0,6,99'
fail unless run_program('2,4,4,5,99,0') == '2,4,4,5,99,9801'
fail unless run_program('1,1,1,4,99,5,6,0,99') == '30,1,1,4,2,5,6,0,99'

prog = IO.read('02.input').split(',').map(&:to_i)
prog[1] = 12
prog[2] = 2

puts run_program(prog.join(',')).split(',').first
