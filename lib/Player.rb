require 'timeout'
require "io/console"

class Player
  def self.play(curr_index, moves_length)
    state = [curr_index, moves_length]
    validateFunc = nil
    actFunc = method(:act)
    Player.handle_input(validateFunc, actFunc, *state)
  end
  
  def self.act(input, state)
    curr_index, moves_length = state[0], state[1]
    case input
    when "+1"
      return (curr_index+1)%moves_length
    when "-1"
      return (curr_index-1+moves_length)%moves_length
    when "submit"
      return "."
    when "reset"
      return "<"
    when "exit"
      return "e"
    when "hard_exit"
      return "fe"
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
    valid_keys = key_to_command.keys
    is_valid_key = valid_keys.include?(input)
    if is_valid_key then
      return key_to_command[input]
    end
    return nil
  end
end