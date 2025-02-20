require_relative "./Piece"

class Rook < Piece

  attr_reader :id
  def initialize(id = "R")
    @id = id
  end

  def moves(game_state)
    board = game_state[:board]
    color = @id[2]
    y, x = board.get_location(@id)
    ds = []
    default_moves = [[-1, 0], [0, 1], [1, 0], [0, -1]]
    for dy, dx in default_moves do
      ny, nx = y+dy, x+dx
      board_status = board.status(ny, nx)
      while board_status == "E" do
        ds.push([ny-y, nx-x])
        ny, nx = ny+dy, nx+dx
        board_status = board.status(ny, nx)
      end
      if ![color, nil].include?(board_status) then
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