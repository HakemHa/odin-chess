class Grid

  def initialize
    @board = Array.new(8) { Array.new(8) }
  end

  def place(y, x, piece)
    @board[y][x] = piece
  end

  def remove(y, x)
    @board[y][x] = nil
  end

  def status(y, x)
    if y < 0 || y > 7 || x < 0 || x > 7 then
      return nil
    elsif @board[y][x].nil? then
      return "E"
    else
      piece = @board[y][x]
      return piece.id[piece.id.length-1]
    end
  end

  def get_location(id)
    for y in 0...@board.length do
      for x in 0...@board[y].length do
        if !@board[y][x].nil? && @board[y][x].id == id then
          return y, x
        end
      end
    end
  end
end