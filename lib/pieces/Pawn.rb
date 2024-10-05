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
    if location[1] < 7 && !board.board[location[0]+move][location[1]+1].nil? then
      valid_moves.push([location[0]+move, location[1]+1])
    end
    if location[1] > 0 && !board.board[location[0]+move][location[1]-1].nil? then
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
    location = board.get_location(@id)
    pawn_to_left = location[1] > 0 && !board.board[location[0]][location[1]-1].nil? && board.board[location[0]][location[1]-1].id[0] == "P"
    if pawn_to_left then
      if story[story.length-1][1] == [location[0], location[1]-1] then
        return -1
      end
    end
    pawn_to_right = location[1] > 0 && !board.board[location[0]][location[1]+1].nil? && board.board[location[0]][location[1]+1].id[0] == "P"
    if pawn_to_right then
      if story[story.length-1][1] == [location[0], location[1]+1] then
        return +1
      end
    end
    return nil
  end
end