require_relative "./Piece"

class King < Piece

  attr_reader :id
  def initialize(id = "K")
    @id = id
    @color = id[id.length-1]
  end
 
  def moves(game_state)
    board = game_state[:board]
    color = @id[2]
    y, x = board.get_location(@id)
    ds = []
    default_moves = [[-1, 1], [1, 1], [1, -1], [-1, -1], [-1, 0], [0, 1], [1, 0], [0, -1]]
    for dy, dx in default_moves do
      ny, nx = y+dy, x+dx
      board_status = board.status(ny, nx)
      if ![color, nil].include?(board_status) then
        ds.push([ny-y, nx-x])
      end
    end
    
    ans = []
    for dy, dx in ds do
      ans.push([y+dy, x+dx])
    end
    ans += get_castle(game_state)
    return ans
  end

  def get_castle(game_state)
    castle = []
    story = game_state[:story]
    king_start = @id[2] == "W" ? [7, 4] : [0, 4]
    king_moved = story.find { |move1, move2, piece| move1 == king_start }
    if !king_moved then
      unavailable_columns = get_unavailable_columns(game_state)
      left_rook_moved = story.find { |move1, move2, piece| move1 == [king_start[0], 0] }
      if !left_rook_moved then
        in_between_columns = [1, 2, 3, 4]
        intersects = unavailable_columns.any? { |col| in_between_columns.include?(col) }
        if !intersects then
          castle.push([king_start[0], king_start[1]-2])
        end
      end 
      right_rook_moved = story.find { |move1, move2, piece| move1 == [king_start[0], 7] }
      if !right_rook_moved then
        in_between_columns = [4, 5, 6]
        intersects = unavailable_columns.any? { |col| in_between_columns.include?(col) }
        if !intersects then
          castle.push([king_start[0], king_start[1]+2])
        end
      end 
    end
    return castle
  end

  def get_unavailable_columns(game_state)
    unavailable_columns = []
    board = game_state[:board]
    color = @id[2]
    row_index = color == "W" ? 7 : 0
    for row in board.board do
      for piece in row do
        if !piece.nil? && piece.id[2] != color then
          piece_location = board.get_location(piece.id)
          if piece_location[0] == row_index then
            unavailable_columns |= [piece_location[1]]
          end
          if piece.id[0] == "K" then
            if (piece_location[0]-row_index).abs <= 1 then
              unavailable_columns |= [piece_location[1], [piece_location[1]+1, 7].max, [piece_location[1]-1, 0].min]
            end
          else
            for move in piece.moves(game_state) do
              if move[0] == row_index then
                unavailable_columns |= [move[1]]
              end
            end
          end
        end
      end
    end
    return unavailable_columns
  end
end