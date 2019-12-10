#!/usr/bin/env ruby
# frozen_string_literal: true

input = IO.read('02.input').split(',').map(&:to_i)

(0..99).each do |pos1|
  (0..99).each do |pos2|
    prog = input.dup

    prog[1] = pos1.dup
    prog[2] = pos2.dup

    prog.each_slice(4) do |chunk|
      break if chunk[0] == 99

      if chunk[0] == 1
        prog[chunk[3]] = prog[chunk[1]] + prog[chunk[2]]
      elsif chunk[0] == 2
        prog[chunk[3]] = prog[chunk[1]] * prog[chunk[2]]
      end
    end

    if prog[0] == 19_690_720
      puts 100 * pos1 + pos2
      exit
    end
  end
end
