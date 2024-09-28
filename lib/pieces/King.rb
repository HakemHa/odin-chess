require_relative "./Piece"

class Rook < Piece

  attr_reader :id
  def initialize(id = "K")
    @id = id
  end

  def moves(board)
    y, x = board.get_location(@id)
    ds = []
    default_moves = [[-1, 1], [1, 1], [1, -1], [-1, -1], [-1, 0], [0, 1], [1, 0], [0, -1]]
    for dy, dx in default_moves do
      ny, nx = y+dy, x+dx
      if board.empty?(ny, nx) then
        ds.push([ny-y, nx-x])
      end
    end
    ans = []
    for dy, dx in ds do
      ans.push([y+dy, x+dx])
    end
    return ans
  end
end