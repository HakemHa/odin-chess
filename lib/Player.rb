require 'timeout'
require "io/console"

class Player
  def initialize(name = "Joe")
    @name = name
  end

  def play(coords, curr_index, moves)
    state = [coords, curr_index, moves]
    validateFunc = nil
    actFunc = method(:act)
    Player.handle_input(validateFunc, actFunc, *state)
  end
  
  def act(input, state)
    coords, curr_index, moves = state[0], state[1], state[2]
    case input
    when "+1"
      if coords.length == 1 then
        return [moves[(curr_index+1)%moves.length]]
      else
        return [coords[0], moves[(curr_index+1)%moves.length]]
      end
    when "-1"
      if coords.length == 1 then
        return [moves[(curr_index-1+moves.length)%moves.length]]
      else
        return [coords[0], moves[(curr_index-1+moves.length)%moves.length]]
      end
    when "submit"
      return coords + ["."]
    when "reset"
      return [coords[0]]
    when "exit"
      return ["e"]
    when "hard_exit"
      return ["fe"]
    else
      return coords
    end
  end
  
  def self.key_to_command
    {
      "\e[A" => "+1", 
      "\e[B" => "-1", 
      "\e[C" => "+1", 
      "\e[D" => "-1", 
      " " => "submit", 
      "\r" => "submit", 
      "\u007F" => "reset", 
      "e" => "exit", 
      "q" => "exit",
      "\u0003" => "hard_exit",
    }
  end
  
  def self.handle_input(validate, act, *state)
    if validate.nil? then
      validate = method(:validate)
    end
    input = nil
    while input.nil? do
      input = STDIN.getch
      chars_in_queue = true
      while chars_in_queue do
        chars_in_queue = false
        begin
          input += Timeout::timeout(0.01) {
            STDIN.getch
          }
        rescue
          chars_in_queue = false
        end
      end
      input = validate.call(input)
    end
    return act.call(input, state)
  end

  def self.validate(input)
    key_to_command = Player.key_to_command
    valid_keys = key_to_command.keys()
    is_valid_key = valid_keys.include?(input)
    if is_valid_key then
      return key_to_command[input]
    end
    return nil
  end
end