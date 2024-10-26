require 'timeout'
require "io/console"

class Player
  def self.play
    actFunc = method(:act)
    Player.handle_input(actFunc)
  end
  
  def self.act(input)
    case input
    when "up"
      return "up"
    when "down"
      return "down"
    when "right"
      return "right"
    when "left"
      return "left"
    when "submit"
      return "."
    when "reset"
      return "<"
    when "p"
      return "prev"
    when "n"
      return "next"
    when "s"
      return "save"
    else
      return nil
    end
  end
  
  def self.key_to_command
    {
      "\e[A" => "up", 
      "\e[B" => "down", 
      "\e[C" => "right", 
      "\e[D" => "left", 
      " " => "submit", 
      "\r" => "submit", 
      "\u007F" => "reset", 
      "\u0003" => "fe",
    }
  end
  
  def self.handle_input(act)
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
      input = validate(input)
      return input if exit_codes.include?(input)
      input = act.call(input)
    end
    return input
  end

  def self.validate(input)
    key_to_command = Player.key_to_command
    valid_keys = key_to_command.keys
    is_valid_key = valid_keys.include?(input)
    if is_valid_key then
      return key_to_command[input]
    end
    if (input.ord >= 'a'.ord && input.ord <= 'z'.ord) || (input.ord >= 'A'.ord && input.ord <= 'Z'.ord) then
      return input
    end
    return nil
  end

  def self.exit_codes
    ["e", "fe", "q"]
  end
end