require_relative "./Piece"

class Pawn < Piece

  attr_reader :id
  def initialize(id = "P")
    @id = id
  end

  def moves(game_state)
    board = game_state[:board]
    color = @id[2]
    location = board.get_location(@id)
    start_row = color == "W" ? 6 : 1
    move = color == "W" ? -1 : 1
    valid_moves = []
    if board.board[location[0]+move][location[1]].nil? then
      valid_moves.push([location[0]+move, location[1]])
    end
    if valid_moves.length > 0 && location[0] == start_row then
      if board.board[location[0]+2*move][location[1]].nil? then
        valid_moves.push([location[0]+2*move, location[1]])
      end
    end
    if location[1] < 7 && !board.board[location[0]+move][location[1]+1].nil? && board.board[location[0]+move][location[1]+1].id[2] != color then
      valid_moves.push([location[0]+move, location[1]+1])
    end
    if location[1] > 0 && !board.board[location[0]+move][location[1]-1].nil? && board.board[location[0]+move][location[1]-1].id[2] != color  then
      valid_moves.push([location[0]+move, location[1]-1])
    end
    en_passant = get_en_passant(game_state)
    if !en_passant.nil? then
      valid_moves.push([location[0]+move, location[1]+en_passant])
    end
    return valid_moves
  end

  def get_en_passant(game_state)
    board = game_state[:board]
    story = game_state[:story]
    if story.length == 0 then
      return nil
    end
    my_row, my_col = board.get_location(@id)
    color = @id[2]
    passant_row = color == "W" ? 3 : 4
    if my_row != passant_row then
      return nil
    end
    last_move_row, last_move_col = story[story.length-1][1]
    if last_move_row != passant_row then
      return nil
    end
    close = (my_col-last_move_col).abs == 1
    if !close then
      return nil
    end
    is_enemy = board.board[last_move_row][last_move_col].id[2] != color
    is_pawn = board.board[last_move_row][last_move_col].id[0] == "P"
    if is_enemy && is_pawn then
      return (last_move_col-my_col)
    end
    return nil
  end
end
