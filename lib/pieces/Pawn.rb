require_relative "./Piece"

class Pawn < Piece

  attr_reader :id
  def initialize(id = "P")
    @id = id
  end

  def moves(board)
    y, x = board.get_location(@id)
    ds = []
    if y != 0 then
      ds.push([-1, 0])
    end
    if @id[@id.length-1] == "B" then
      for d in ds do
        dy, dx = -d[0], -d[1]
        d = [y, x]
      end
    end
    ans = []
    for dy, dx in ds do
      ans.push([y+dy, x+dx])
    end
    return ans
  end
end