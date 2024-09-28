require_relative "./Piece"

class Pawn < Piece

  attr_reader :id
  def initialize(id = "P")
    @id = id
    @color = id[id.length-1]
  end

  def moves(board)
    y, x = board.get_location(@id)
    ds = [[-1, 0]]
    diags = [[-1, 1], [-1, -1]]
    if @color == "B" then
      for d in ds do
        dy, dx = -d[0], -d[1]
        d[0], d[1] = dy, dx
      end
      for d in diags do
        dy, dx = -d[0], -d[1]
        d[0], d[1] = dy, dx
      end
    end
    if @color == "W" && y == 6 then
      ds.push([-2, 0])
    elsif @color == "B" && y == 1 then
      ds.push([2, 0])
    end
    ans = []
    for dy, dx in ds do
      board_status = board.status(y+dy, x+dx)
      if board_status == "E" then
        ans.push([y+dy, x+dx])
      end
    end
    for dy, dx in diags do
      board_status = board.status(y+dy, x+dx)
      if ![nil, @color, "E"].include?(board_status) then
        ans.push([y+dy, x+dx])
      end
    end
    return ans
  end
end