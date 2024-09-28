require_relative "./Piece"

class Knight < Piece

  attr_reader :id
  def initialize(id = "H")
    @id = id
    @color = id[id.length-1]
  end

  def moves(board)
    y, x = board.get_location(@id)
    ds = []
    default_moves = [[-2, -1], [-1, 2], [2, 1], [1, -2], [-2, 1], [1, 2], [2, -1], [-1, -2]]
    for dy, dx in default_moves do
      ny, nx = y+dy, x+dx
      board_status = board.status(ny, nx)
      if ![@color, nil].include?(board_status) then
        ds.push([dy, dx])
      end
    end
    ans = []
    for dy, dx in ds do
      ans.push([y+dy, x+dx])
    end
    return ans
  end
end