#!/usr/bin/env ruby
# frozen_string_literal: true

class Advent
  attr_reader :output

  def initialize(store_output = false, debug_switch = false)
    @store_output = store_output
    @debug = debug_switch
  end

  def debug(msg)
    print msg if @debug
  end

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
    debug "writing #{@input} to #{prog[pc + 1]}"
    prog[prog[pc + 1]] = @input
    [prog, pc + 2]
  end

  # Opcode 4 outputs the value of its only parameter. For example, the
  # instruction 4,50 would output the value at address 50.
  #
  def opcode_4(prog, pc, params)
    @output = value(prog, pc + 1, params[-1])
    puts @output unless @store_output
    [prog, pc + 2]
  end

  # Opcode 5 is jump-if-true: if the first parameter is non-zero, it sets the
  # instruction pointer to the value from the second parameter. Otherwise, it
  # does nothing.
  #
  def opcode_5(prog, pc, params)
    new_pc = if value(prog, pc + 1, params[-1]).zero?
               pc + 3
             else
               value(prog, pc + 2, params[-2])
             end

    [prog, new_pc]
  end

  # Opcode 6 is jump-if-false: if the first parameter is zero, it sets the
  # instruction pointer to the value from the second parameter. Otherwise, it
  # does nothing.
  #
  def opcode_6(prog, pc, params)
    new_pc = if value(prog, pc + 1, params[-1]).zero?
               value(prog, pc + 2, params[-2])
             else
               pc + 3
             end

    [prog, new_pc]
  end

  # Opcode 7 is less than: if the first parameter is less than the second
  # parameter, it stores 1 in the position given by the third parameter.
  # Otherwise, it stores 0.
  #
  def opcode_7(prog, pc, params)
    prog[prog[pc + 3]] = if value(prog, pc + 1, params[-1]) < value(prog, pc + 2, params[-2])
                           1
                         else
                           0
                         end

    [prog, pc + 4]
  end

  # Opcode 8 is equals: if the first parameter is equal to the second parameter,
  # it stores 1 in the position given by the third parameter. Otherwise, it
  # stores 0.
  #
  def opcode_8(prog, pc, params)
    prog[prog[pc + 3]] = if value(prog, pc + 1, params[-1]) == value(prog, pc + 2, params[-2])
                           1
                         else
                           0
                         end

    [prog, pc + 4]
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

  def run!(prog, input)
    pc = 0
    prog = prog.split(',').map(&:to_i)
    @input = input

    loop do
      op = prog[pc]
      break if op == 99

      opcode, params = decoded_op(op)

      method = "opcode_#{opcode}".to_sym
      debug "calling #{method} with #{prog} #{pc} #{params}"
      prog, pc = send(method, prog, pc, params)
    end

    @output
  end
end

ADV = Advent.new(true)

fail unless ADV.run!('3,9,8,9,10,9,4,9,99,-1,8', 8) == 1
fail unless ADV.run!('3,9,8,9,10,9,4,9,99,-1,8', 4) == 0
fail unless ADV.run!('3,9,7,9,10,9,4,9,99,-1,8', 4) == 1
fail unless ADV.run!('3,9,7,9,10,9,4,9,99,-1,8', 8) == 0
fail unless ADV.run!('3,3,1108,-1,8,3,4,3,99', 8) == 1
fail unless ADV.run!('3,3,1108,-1,8,3,4,3,99', 5) == 0
fail unless ADV.run!('3,3,1107,-1,8,3,4,3,99', 5) == 1
fail unless ADV.run!('3,3,1107,-1,8,3,4,3,99', 9) == 0

fail unless ADV.run!('3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9', 0) == 0
fail unless ADV.run!('3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9', 4) == 1
fail unless ADV.run!('3,3,1105,-1,9,1101,0,0,12,4,12,99,1', 0) == 0
fail unless ADV.run!('3,3,1105,-1,9,1101,0,0,12,4,12,99,1', 1) == 1

prog = '3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,' \
'0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,' \
'1,46,98,99'

fail unless ADV.run!(prog, 1) == 999
fail unless ADV.run!(prog, 8) == 1000
fail unless ADV.run!(prog, 11) == 1001

# Answer the question

puts ADV.run!(IO.read('05.input'), 5)
