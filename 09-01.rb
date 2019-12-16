#!/usr/bin/env ruby
# frozen_string_literal: true

class IntcodeComputer
  attr_reader :output, :state

  USE_STATE = false # set to true if you need the computer to be stop and resume

  def initialize(store_output = false, debug_switch = false)
    @store_output = store_output
    @debug = debug_switch
    @state = :running
    @stored_state = nil
    @output = []
    @relative_base = 0
  end

  def debug(msg)
    puts msg if @debug
  end

  # Fetch a value from the correct address
  #
  def addr(prog, addr, params, offset)
    case params[-offset]
    when 0 # position mode
      prog[addr + offset]
    when 1 # immediate mode
      addr + offset
    when 2 # relative mode
      @relative_base + prog[addr + offset]
    else
      abort "unexpected mode [#{params[-offset]}"
    end
  end

  def value(prog, addr, params, offset)
    address = addr(prog, addr, params, offset)
    abort 'negative address' if address < 0
    prog.fetch(address, 0)
  end

  # @return [prog, pc]
  #
  def opcode_1(prog, pc, params)
    debug "write mode #{params[-3]}"
    prog[addr(prog, pc, params, 3)] = value(prog, pc, params, 1) + value(prog, pc, params, 2)
    [prog, pc + 4]
  end

  def opcode_2(prog, pc, params)
    debug "write mode #{params[-3]}"
    prog[addr(prog, pc, params, 3)] = value(prog, pc, params, 1) * value(prog, pc, params, 2)
    [prog, pc + 4]
  end

  # Opcode 3 takes a single integer as input and saves it to the position given
  # by its only parameter.
  #
  def opcode_3(prog, pc, params)
    input = @input.shift
    addr = addr(prog, pc, params, 1)
    prog[addr] = input
    [prog, pc + 2]
  end

  # Opcode 4 outputs the value of its only parameter. For example, the
  # instruction 4,50 would output the value at address 50.
  #
  def opcode_4(prog, pc, params)
    @output.<< value(prog, pc, params, 1)
    @state = :stop
    [prog, pc + 2]
  end

  # Opcode 5 is jump-if-true: if the first parameter is non-zero, it sets the
  # instruction pointer to the value from the second parameter. Otherwise, it
  # does nothing.
  #
  def opcode_5(prog, pc, params)
    new_pc = if value(prog, pc, params, 1).zero?
               pc + 3
             else
               value(prog, pc, params, 2)
             end

    [prog, new_pc]
  end

  # Opcode 6 is jump-if-false: if the first parameter is zero, it sets the
  # instruction pointer to the value from the second parameter. Otherwise, it
  # does nothing.
  #
  def opcode_6(prog, pc, params)
    new_pc = if value(prog, pc, params, 1).zero?
               value(prog, pc, params, 2)
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
    debug "write mode #{params[-3]}"
    prog[addr(prog, pc, params, 3)] = if value(prog, pc, params, 1) <
                                         value(prog, pc, params, 2)
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
    prog[addr(prog, pc, params, 3)] = if value(prog, pc, params, 1) ==
                                         value(prog, pc, params, 2)
                                        1
                                      else
                                        0
                         end

    [prog, pc + 4]
  end

  # Opcode 9 adjusts the relative base by the value of its only parameter.
  #
  def opcode_9(prog, pc, params)
    @relative_base += prog[addr(prog, pc, params, 1)]
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

  # @param input [Array[Integer]]
  #
  def run!(prog, input = [])
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
      debug "calling #{method}" # with #{prog} #{pc} #{params}"
      prog, pc = send(method, prog, pc, params)

      # prog = prog.map { |a| a.nil? ? 0 : a }

      break if USE_STATE && @state != :running
    end

    @stored_pc = pc
    @stored_state = prog
    @output.join(',')
  end
end

IC1 = IntcodeComputer.new
quine_prog = '109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99'
raise unless IC1.run!(quine_prog) == quine_prog

IC2 = IntcodeComputer.new
raise unless IC2.run!('1102,34915192,34915192,7,4,7,99,0').size == 16

IC3 = IntcodeComputer.new
raise unless IC3.run!('104,1125899906842624,99') == '1125899906842624'

prog = IO.read('09.input')

IC = IntcodeComputer.new
puts IC.run!(prog, [1])
