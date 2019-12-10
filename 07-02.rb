#!/usr/bin/env ruby
# frozen_string_literal: true

class IntcodeComputer
  attr_reader :output, :state

  def initialize(store_output = false, debug_switch = false)
    @store_output = store_output
    @debug = debug_switch
    @state = :running
    @stored_state = nil
  end

  def debug(msg)
    puts msg if @debug
  end

  # If the param is zero, use address mode (return value pointed to by given
  # address), if it's one, use immediate mode (return value at given address)
  #
  def value(prog, addr, param)
    param == 1 ? prog[addr] : prog[prog[addr]]
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
    prog[prog[pc + 1]] = input
    [prog, pc + 2]
  end

  # Opcode 4 outputs the value of its only parameter. For example, the
  # instruction 4,50 would output the value at address 50.
  #
  def opcode_4(prog, pc, params)
    @output = value(prog, pc + 1, params[-1])
    @state = :stop
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
    @state = :running
    pc = @stored_pc || 0
    prog = @stored_state || prog.split(',').map(&:to_i)
    @input = input

    loop do
      op = prog[pc]

      if op == 99
        @state = :halted
        break
      end

      opcode, params = decoded_op(op)

      method = "opcode_#{opcode}".to_sym
      #debug "calling #{method} with #{prog} #{pc} #{params}"
      prog, pc = send(method, prog, pc, params)

      break unless @state == :running
    end

    @stored_pc = pc
    @stored_state = prog
    @output
  end
end

def machine_chain(prog, inputs)
  machine_a = IntcodeComputer.new(true)
  machine_b = IntcodeComputer.new(true)
  machine_c = IntcodeComputer.new(true)
  machine_d = IntcodeComputer.new(true)
  machine_e = IntcodeComputer.new(true)

  a_out = machine_a.run!(prog, [inputs[0], 0])
  b_out = machine_b.run!(prog, [inputs[1], a_out])
  c_out = machine_c.run!(prog, [inputs[2], b_out])
  d_out = machine_d.run!(prog, [inputs[3], c_out])
  e_out = machine_e.run!(prog, [inputs[4], d_out])

  loop do
    a_out = machine_a.run!(prog, [e_out])
    b_out = machine_b.run!(prog, [a_out])
    c_out = machine_c.run!(prog, [b_out])
    d_out = machine_d.run!(prog, [c_out])
    e_out = machine_e.run!(prog, [d_out])
    break if machine_e.state == :halted
  end

  machine_e.output
end

raise unless machine_chain('3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,' \
                           '27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5',
                           [9, 8, 7, 6, 5]) == 139629729

raise unless machine_chain('3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,' \
                           '55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,' \
                           '53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,' \
                           '1001,56,-1,56,1005,56,6,99,0,0,0,0,10',
                           [9, 7, 8, 5, 6]) == 18216

prog = IO.read('07.input')
puts [5, 6, 7, 8, 9].permutation.map { |p| machine_chain(prog, p) }.max
