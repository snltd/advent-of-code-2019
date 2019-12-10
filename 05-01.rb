#!/usr/bin/env ruby
# frozen_string_literal: true

prog = IO.read('05.input').split(',').map(&:to_i)

INPUT = 1

# If the param is zero, use address mode (return value pointed to by given
# address), if it's one, use immediate mode (return value at given address)
#
def value(prog, addr, param)
  if param == 1
    prog[addr]
  else
    prog[prog[addr]]
  end
end

# @return [prog, pc]
#
def opcode_1(prog, pc, params)
  prog[prog[pc + 3]] = value(prog, pc + 1, params[-1]) +
                       value(prog, pc + 2, params[-2])
  [prog, pc + 4]
end

def opcode_2(prog, pc, params)
  prog[prog[pc + 3]] = value(prog, pc + 1, params[-1]) *
                       value(prog, pc + 2, params[-2])
  [prog, pc + 4]
end

# Opcode 3 takes a single integer as input and saves it to the position given
# by its only parameter.
#
def opcode_3(prog, pc, _params)
  prog[prog[pc + 1]] = INPUT
  [prog, pc + 2]
end

# Opcode 4 outputs the value of its only parameter. For example, the
# instruction 4,50 would output the value at address 50.
#
def opcode_4(prog, pc, _params)
  puts prog[prog[pc + 1]]
  [prog, pc + 2]
end

# Given a 5-digit opcode/parameter,
# @return [opcode, [params]]
#
def decoded_op(op)
  op = format('%05d', op)

  opcode = op.to_s[-2..-1].to_i
  params = op.to_s[0..2].chars.map(&:to_i)

  [opcode, params]
end

pc = 0

loop do
  op = prog[pc]
  break if op == 99

  opcode, params = decoded_op(op)

  method = "opcode_#{opcode}".to_sym
  prog, pc = send(method, prog, pc, params)
end
