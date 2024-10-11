require_relative "./Game"

class Computer
  def self.play(mode, game_state)
    case mode
    when "Random"
      return play_random(game_state)
    when "Easy"
      return play_alpha_beta(2, game_state)
    when "Medium"
      return play_alpha_beta(6, game_state)
    when "Hard"
      return play_alpha_beta(14, game_state)
    else
      raise "Not a valid mode Error"
    end
  end

  def self.play_random(game_state)
    valid_moves = Game.get_valid_moves(game_state)
    pieces = valid_moves.keys
    piece = pieces.sample
    moves = valid_moves[piece]
    move = moves.sample
    return [piece, move]
  end

  def self.play_alpha_beta(depth, game_state)
    return nil
  end
end