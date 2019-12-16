#!/usr/bin/env ruby
# frozen_string_literal: true

class IntcodeComputer
  attr_reader :output

  def initialize(store_output = false, debug_switch = false)
    @store_output = store_output
    @debug = debug_switch
  end

  def debug(msg)
    puts msg if @debug
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
    input = @input.shift
    debug "writing #{input} to #{prog[pc + 1]}"
    prog[prog[pc + 1]] = input
    [prog, pc + 2]
  end

  # Opcode 4 outputs the value of its only parameter. For example, the
  # instruction 4,50 would output the value at address 50.
  #
  def opcode_4(prog, pc, params)
    debug "printing value #{value(prog, pc + 1, params[-1])}"
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

  # @param input [Array[Integer]]
  #
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

def machine_chain(prog, inputs)
  machine = IntcodeComputer.new(true)

  a_out = machine.run!(prog, [inputs.shift, 0])
  b_out = machine.run!(prog, [inputs.shift, a_out])
  c_out = machine.run!(prog, [inputs.shift, b_out])
  d_out = machine.run!(prog, [inputs.shift, c_out])
  machine.run!(prog, [inputs.shift, d_out])
end

raise unless machine_chain('3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0',
                           [4, 3, 2, 1, 0]) == 43_210
raise unless machine_chain('3,23,3,24,1002,24,10,24,1002,23,-1,23,' \
                           '101,5,23,23,1,24,23,23,4,23,99,0,0',
                           [0, 1, 2, 3, 4]) == 54_321
raise unless machine_chain('3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,' \
                           '31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,' \
                           '31,99,0,0,0',
                           [1, 0, 4, 3, 2]) == 65_210

prog = IO.read('07.input')

puts [0, 1, 2, 3, 4].permutation.map { |p| machine_chain(prog, p) }.max
