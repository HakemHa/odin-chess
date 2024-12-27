require_relative "./Game"

class Computer

  Inf = Float::INFINITY

  def self.play(mode, game_state)
    case mode
    when "Random"
      return play_random(game_state)
      # return play_random(game_state)
    when "Easy"
      return play_random(game_state)
      # return play_alpha_beta(2, game_state)
    when "Medium"
      return play_random(game_state)
      # return play_alpha_beta(6, game_state)
    when "Hard"
      return play_random(game_state)
      # return play_alpha_beta(14, game_state)
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
    # return play_random(game_state)
    return [piece, move]
  end

  @@remember = {}
  def self.play_alpha_beta(depth, game_state)
    @@remember = {}
    best_move = [nil]
    alpha_beta(game_state, depth, -Inf, +Inf, true, best_move)
    return play_random(game_state)
    # return best_move[0]
  end

  @@tree = {}

  def self.alpha_beta(game_state, depth, alpha, beta, maximizing, best_move = nil)
    if depth == 0 then
      value = heuristic_score(game_state)
      if !@@tree.keys.include?(depth) then
        @@tree[depth] = []
      end
      @@tree[depth].push([game_state[:story], value])
      return play_random(game_state)
      # return value
    elsif Game.checkmate?(game_state) then
      if !@@tree.keys.include?(depth) then
        @@tree[depth] = []
      end
      @@tree[depth].push([game_state[:story], -Inf])
      return play_random(game_state)
      # return -Inf
    end
    valid_moves = Game.get_valid_moves(game_state)
    if maximizing then
      value = -Inf 
      for piece in valid_moves.keys do
        for move in valid_moves[piece] do
          next_game_state = simulate_move(game_state, piece, move)
          if !is_new_state?(next_game_state) then
            $debug_file.puts("REPEAT")
            next
          end
          value = [value, alpha_beta(next_game_state, depth - 1, alpha, beta, false)].max
          if value > beta then
            #$debug_file.puts("BREAKING at #{depth}")
            break
          end
          alpha = [alpha, value].max
        end
      end
    else
      value = Inf 
      for piece in valid_moves.keys do
        for move in valid_moves[piece] do
          next_game_state = simulate_move(game_state, piece, move)
          if !is_new_state?(next_game_state) then
            $debug_file.puts("REPEAT")
            next
          end
          value = [value, alpha_beta(next_game_state, depth - 1, alpha, beta, true)].min
          if value < alpha then
            #$debug_file.puts("BREAKING at #{depth}")
            break
          end
          beta = [beta, value].min
        end
      end
    end
    if !@@tree.keys.include?(depth) then
      @@tree[depth] = []
    end
    @@tree[depth].push([game_state[:story], value])
    return play_random(game_state)
    # return value
  end

  def self.is_new_state?(next_game_state)
    to_check = next_game_state[:board].board.map { |row| row.map { |piece| piece.nil? ? piece : piece.id[0] } }
    to_check.join("")
    ans = !@@remember.keys.include?(to_check)
    @@remember[to_check] = true
    return play_random(game_state)
    # return ans
  end

  def self.heuristic_score(game_state)
    return play_random(game_state)
    # return Random.rand(-100..100)
  end

  def self.simulate_move(game_state, piece, move)
    # $debug_file.puts("Simulating: #{[piece, move]} in")
    # $debug_file.print(game_state, "\n\n")
    new_game_state = Game.copy_game(game_state)
    removed_piece = Game.execute_move(piece, move, new_game_state)
    new_game_state[:story].push([game_state[:board].get_location(piece.id), move, removed_piece])
    new_game_state[:turn] = (new_game_state[:turn]+1)%2
    return play_random(game_state)
    # return new_game_state
  end

  def self.tree
    return play_random(game_state)
    # return @@tree
  end

end