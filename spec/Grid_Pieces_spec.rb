Dir[File.join(__dir__, '../lib/pieces', "*")].each { |file| require file }
require_relative "../lib/Grid"

describe "Grid" do
  describe "#initialize" do
    context "when initialized" do
      it "creates empty board" do
        new_grid = Grid.new
        board = new_grid.instance_variable_get(:@board)
        test = [[nil, nil, nil, nil, nil, nil, nil, nil],[nil, nil, nil, nil, nil, nil, nil, nil],[nil, nil, nil, nil, nil, nil, nil, nil],[nil, nil, nil, nil, nil, nil, nil, nil],[nil, nil, nil, nil, nil, nil, nil, nil],[nil, nil, nil, nil, nil, nil, nil, nil],[nil, nil, nil, nil, nil, nil, nil, nil],[nil, nil, nil, nil, nil, nil, nil, nil]]
        expect(board).to eq(test)
      end
    end
  end

  describe "Moves:" do
    context "when placing a white pawn" do
      it "can move forward if grid is empty" do
        move_grid = Grid.new
        pawn = Pawn.new("P1W")
        move_grid.place(7, 1, pawn)
        state = {board: move_grid, story: []}
        result = pawn.moves(state)
        expected = [[6, 1]]
        expect(result).to eq(expected)
      end

      it "can move twice forward if first move" do
        move_grid = Grid.new
        pawn = Pawn.new("P1W")
        move_grid.place(6, 1, pawn)
        state = {board: move_grid, story: []}
        result = pawn.moves(state)
        expected = [[5, 1], [4, 1]]
        expect(result).to eq(expected)
      end

      it "can't move forward if grid is occupied" do
        move_grid = Grid.new
        pawn = Pawn.new("P1W")
        move_grid.place(7, 1, pawn)
        move_grid.place(6, 1, Pawn.new("P2B"))
        state = {board: move_grid, story: []}
        result = pawn.moves(state)
        expected = []
        expect(result).to eq(expected)
      end

      it "can eat diagonally" do
        move_grid = Grid.new
        pawn = Pawn.new("P1W")
        move_grid.place(7, 1, pawn)
        move_grid.place(6, 0, Pawn.new("P2B"))
        move_grid.place(6, 2, Pawn.new("P2B"))
        state = {board: move_grid, story: []}
        result = pawn.moves(state)
        expected = [[6, 1], [6, 0], [6, 2]]
        expect(((result-expected) + (expected-result))).to be_empty
      end

      it "can en passant" do
        move_grid = Grid.new
        pawn = Pawn.new("P1W")
        move_grid.place(3, 4, pawn)
        move_grid.place(3, 3, Pawn.new("P2B"))
        state = {board: move_grid, story: [[[1, 3], [3, 3], nil]]}
        result = pawn.moves(state)
        expected = [[2, 3], [2, 4]]
        expect(((result-expected) + (expected-result))).to be_empty
      end

      it "can't en passant if enemy pawn hasn't just moved two squares forward" do
        move_grid = Grid.new
        pawn = Pawn.new("P1W")
        move_grid.place(3, 4, pawn)
        move_grid.place(3, 3, Pawn.new("P2B"))
        state = {board: move_grid, story: [[[1, 3], [3, 3], nil], [[0, 0], [0, 0], nil]]}
        result = pawn.moves(state)
        expected = [[2, 4]]
        expect(((result-expected) + (expected-result))).to be_empty
      end

      it "can't en passant if enemy pawn hasn't moved two squares forward" do
        move_grid = Grid.new
        pawn = Pawn.new("P1W")
        move_grid.place(2, 4, pawn)
        move_grid.place(2, 3, Pawn.new("P2B"))
        state = {board: move_grid, story: [[[1, 3], [2, 3], nil]]}
        result = pawn.moves(state)
        expected = [[1, 4]]
        expect(((result-expected) + (expected-result))).to be_empty
      end

      it "can't en passant if enemy isn't pawn" do
        move_grid = Grid.new
        pawn = Pawn.new("P1W")
        move_grid.place(3, 4, pawn)
        move_grid.place(3, 3, Rook.new("R2B"))
        state = {board: move_grid, story: [[[1, 3], [3, 3], nil]]}
        result = pawn.moves(state)
        expected = [[2, 4]]
        expect(((result-expected) + (expected-result))).to be_empty
      end

      it "can't en passant if enemy pawn isn't adjacent" do
        move_grid = Grid.new
        pawn = Pawn.new("P1W")
        move_grid.place(3, 4, pawn)
        move_grid.place(3, 1, Pawn.new("P2B"))
        state = {board: move_grid, story: [[[1, 1], [3, 1], nil]]}
        result = pawn.moves(state)
        expected = [[2, 4]]
        expect(((result-expected) + (expected-result))).to be_empty
      end
    end

    context "when placing a black pawn" do
      it "can move forward if grid is empty" do
        move_grid = Grid.new
        pawn = Pawn.new("P1B")
        move_grid.place(0, 1, pawn)
        state = {board: move_grid, story: []}
        result = pawn.moves(state)
        expected = [[1, 1]]
        expect(result).to eq(expected)
      end

      it "can move twice forward if first move" do
        move_grid = Grid.new
        pawn = Pawn.new("P1B")
        move_grid.place(1, 1, pawn)
        state = {board: move_grid, story: []}
        result = pawn.moves(state)
        expected = [[2, 1], [3, 1]]
        expect(result).to eq(expected)
      end

      it "can't move forward if grid is occupied" do
        move_grid = Grid.new
        pawn = Pawn.new("P1B")
        move_grid.place(0, 1, pawn)
        move_grid.place(1, 1, Pawn.new("P2W"))
        state = {board: move_grid, story: []}
        result = pawn.moves(state)
        expected = []
        expect(result).to eq(expected)
      end

      it "can eat diagonally" do
        move_grid = Grid.new
        pawn = Pawn.new("P1B")
        move_grid.place(0, 1, pawn)
        move_grid.place(1, 0, Pawn.new("P2w"))
        move_grid.place(1, 2, Pawn.new("P2w"))
        state = {board: move_grid, story: []}
        result = pawn.moves(state)
        expected = [[1, 1], [1, 0], [1, 2]]
        expect(((result-expected) + (expected-result))).to be_empty
      end

      it "can en passant" do
        move_grid = Grid.new
        pawn = Pawn.new("P1B")
        move_grid.place(4, 4, pawn)
        move_grid.place(4, 3, Pawn.new("P2W"))
        state = {board: move_grid, story: [[[6, 3], [4, 3], nil]]}
        result = pawn.moves(state)
        expected = [[5, 3], [5, 4]]
        expect(((result-expected) + (expected-result))).to be_empty
      end

      it "can't en passant if enemy pawn hasn't just moved two squares forward" do
        move_grid = Grid.new
        pawn = Pawn.new("P1B")
        move_grid.place(4, 4, pawn)
        move_grid.place(4, 3, Pawn.new("P2W"))
        state = {board: move_grid, story: [[[6, 3], [5, 3], nil], [[0, 0], [0, 0], nil]]}
        result = pawn.moves(state)
        expected = [[5, 4]]
        expect(((result-expected) + (expected-result))).to be_empty
      end

      it "can't en passant if enemy pawn hasn't moved two squares forward" do
        move_grid = Grid.new
        pawn = Pawn.new("P1B")
        move_grid.place(5, 4, pawn)
        move_grid.place(5, 3, Pawn.new("P2W"))
        state = {board: move_grid, story: [[[6, 3], [5, 3], nil]]}
        result = pawn.moves(state)
        expected = [[6, 4]]
        expect(((result-expected) + (expected-result))).to be_empty
      end

      it "can't en passant if enemy isn't pawn" do
        move_grid = Grid.new
        pawn = Pawn.new("P1B")
        move_grid.place(4, 4, pawn)
        move_grid.place(4, 3, Rook.new("R2W"))
        state = {board: move_grid, story: [[[6, 3], [4, 3], nil]]}
        result = pawn.moves(state)
        expected = [[5, 4]]
        expect(((result-expected) + (expected-result))).to be_empty
      end

      it "can't en passant if enemy pawn isn't adjacent" do
        move_grid = Grid.new
        pawn = Pawn.new("P1B")
        move_grid.place(4, 4, pawn)
        move_grid.place(4, 2, Pawn.new("P2W"))
        state = {board: move_grid, story: [[[6, 2], [4, 2], nil]]}
        result = pawn.moves(state)
        expected = [[5, 4]]
        expect(((result-expected) + (expected-result))).to be_empty
      end
    end

    context "when placing a rook" do
      it "can move everywhere if grid is empty" do
        move_grid = Grid.new
        rook = Rook.new("R1W")
        move_grid.place(7, 3, rook)
        move_grid.place(4, 0, Pawn.new("P2W"))
        state = {board: move_grid}
        result = rook.moves(state)
        expected = [[6, 3], [5, 3], [4, 3], [3, 3], [2, 3], [1, 3], [0, 3], [7, 2], [7, 1], [7, 0], [7, 4], [7, 5], [7, 6], [7, 7]]
        expect(((result-expected) + (expected-result))).to be_empty, lambda { "The moves received were: #{result}" }
      end

      it "can't move forward if grid is blocked" do
        move_grid = Grid.new
        rook = Rook.new("R1W")
        move_grid.place(7, 3, rook)
        move_grid.place(4, 3, Pawn.new("P2B"))
        state = {board: move_grid}
        result = rook.moves(state)
        expected = [[6, 3], [5, 3], [4, 3], [7, 2], [7, 1], [7, 0], [7, 4], [7, 5], [7, 6], [7, 7]]
        expect(((result-expected) + (expected-result))).to be_empty
      end

      it "can't move forward if grid is blocked by same color" do
        move_grid = Grid.new
        rook = Rook.new("R1W")
        move_grid.place(7, 3, rook)
        move_grid.place(4, 3, Pawn.new("P2W"))
        state = {board: move_grid}
        result = rook.moves(state)
        expected = [[6, 3], [5, 3], [7, 2], [7, 1], [7, 0], [7, 4], [7, 5], [7, 6], [7, 7]]
        expect(((result-expected) + (expected-result))).to be_empty
      end

      it "can't move left and forward if grid is blocked" do
        move_grid = Grid.new
        rook = Rook.new("R1W")
        move_grid.place(7, 3, rook)
        move_grid.place(7, 2, Pawn.new("P2B"))
        move_grid.place(4, 3, Pawn.new("P2B"))
        state = {board: move_grid}
        result = rook.moves(state)
        expected = [[6, 3], [5, 3], [4, 3], [7, 2], [7, 4], [7, 5], [7, 6], [7, 7]]
        expect(((result-expected) + (expected-result))).to be_empty
      end
    end

    context "when placing a knight" do
      it "can move everywhere if grid is empty" do
        move_grid = Grid.new
        knight = Knight.new("H1W")
        move_grid.place(4, 3, knight)
        move_grid.place(4, 0, Pawn.new("P2W"))
        state = {board: move_grid}
        result = knight.moves(state)
        expected = [[2, 2], [2, 4], [3, 5], [5, 5], [6, 2], [6, 4], [3, 1], [5, 1]]
        expect(((result-expected) + (expected-result))).to be_empty,
        lambda { "The moves received were: #{result}" }
      end

      it "can move r[-2, 1] if grid is blocked r[-1, 1]" do
        move_grid = Grid.new
        knight = Knight.new("H1W")
        move_grid.place(4, 3, knight)
        move_grid.place(3, 4, Pawn.new("P2W"))
        state = {board: move_grid}
        result = knight.moves(state)
        expected = [[2, 2], [2, 4], [3, 5], [5, 5], [6, 2], [6, 4], [3, 1], [5, 1]]
        expect(((result-expected) + (expected-result))).to be_empty
      end

      it "can eat at [-2, 1] if grid is occupied" do
        move_grid = Grid.new
        knight = Knight.new("H1W")
        move_grid.place(4, 3, knight)
        move_grid.place(2, 4, Pawn.new("P2B"))
        state = {board: move_grid}
        result = knight.moves(state)
        expected = [[2, 2], [2, 4], [3, 5], [5, 5], [6, 2], [6, 4], [3, 1], [5, 1]]
        expect(((result-expected) + (expected-result))).to be_empty
      end

      it "can't eat at [-2, 1] if grid is occupied by same color" do
        move_grid = Grid.new
        knight = Knight.new("H1W")
        move_grid.place(4, 3, knight)
        move_grid.place(2, 4, Pawn.new("P2W"))
        state = {board: move_grid}
        result = knight.moves(state)
        expected = [[2, 2], [3, 5], [5, 5], [6, 2], [6, 4], [3, 1], [5, 1]]
        expect(((result-expected) + (expected-result))).to be_empty
      end
    end

    context "when placing a bishop" do
      it "can move everywhere if grid is empty" do
        move_grid = Grid.new
        bishop = Bishop.new("B1W")
        move_grid.place(6, 3, bishop)
        move_grid.place(4, 0, Pawn.new("P2W"))
        state = {board: move_grid}
        result = bishop.moves(state)
        expected = [[7, 4], [7, 2], [5, 4], [5, 2], [4, 5], [4, 1], [3, 6], [3, 0], [2, 7]]
        expect(((result-expected) + (expected-result))).to be_empty
      end

      it "can't move beyond r[-2, 2] if grid is blocked" do
        move_grid = Grid.new
        bishop = Bishop.new("B1W")
        move_grid.place(6, 3, bishop)
        move_grid.place(4, 5, Pawn.new("P2B"))
        state = {board: move_grid}
        result = bishop.moves(state)
        expected = [[7, 4], [7, 2], [5, 4], [5, 2], [4, 5], [4, 1], [3, 0]]
        expect(((result-expected) + (expected-result))).to be_empty
      end

      it "can't move r[-2, 2] if grid is occupied by same color" do
        move_grid = Grid.new
        bishop = Bishop.new("B1W")
        move_grid.place(6, 3, bishop)
        move_grid.place(4, 5, Pawn.new("P2W"))
        state = {board: move_grid}
        result = bishop.moves(state)
        expected = [[7, 4], [7, 2], [5, 4], [5, 2], [4, 1], [3, 0]]
        expect(((result-expected) + (expected-result))).to be_empty
      end

      it "can't move beyond r[-2, 2], r[1, -1] if grid is blocked" do
        move_grid = Grid.new
        bishop = Bishop.new("B1W")
        move_grid.place(6, 3, bishop)
        move_grid.place(4, 5, Pawn.new("P2B"))
        move_grid.place(7, 2, Pawn.new("P2B"))
        state = {board: move_grid}
        result = bishop.moves(state)
        expected = [[7, 4], [7, 2], [5, 4], [5, 2], [4, 5], [4, 1], [3, 0]]
        expect(((result-expected) + (expected-result))).to be_empty
      end
    end

    context "when placing a queen" do
      it "can move everywhere if grid is empty" do
        move_grid = Grid.new
        queen = Queen.new("Q1W")
        move_grid.place(4, 3, queen)
        move_grid.place(3, 1, Pawn.new("P2W"))
        state = {board: move_grid}
        result = queen.moves(state)
        expected = [[3, 3], [2, 3], [1, 3], [0, 3], [5, 3], [6, 3], [7, 3], [4, 2], [4, 1], [4, 0], [4, 4], [4, 5], [4, 6], [4, 7], [5, 4], [6, 5], [7, 6], [5, 2], [6, 1], [7, 0], [3, 2], [2, 1], [1, 0], [3, 4], [2, 5], [1, 6], [0, 7]]
        expect(((result-expected) + (expected-result))).to be_empty,
        lambda { "The moves received were: #{result}" }
      end

      it "can't move beyond r[-2, 2] if grid is blocked" do
        move_grid = Grid.new
        queen = Queen.new("Q1W")
        move_grid.place(4, 3, queen)
        move_grid.place(2, 5, Pawn.new("P2B"))
        state = {board: move_grid}
        result = queen.moves(state)
        expected = [[3, 3], [2, 3], [1, 3], [0, 3], [5, 3], [6, 3], [7, 3], [4, 2], [4, 1], [4, 0], [4, 4], [4, 5], [4, 6], [4, 7], [5, 4], [6, 5], [7, 6], [5, 2], [6, 1], [7, 0], [3, 2], [2, 1], [1, 0], [3, 4], [2, 5]]
        expect(((result-expected) + (expected-result))).to be_empty
      end

      it "can't move r[-2, 2] if grid is occupied by same color" do
        move_grid = Grid.new
        queen = Queen.new("Q1W")
        move_grid.place(4, 3, queen)
        move_grid.place(2, 5, Pawn.new("P2W"))
        state = {board: move_grid}
        result = queen.moves(state)
        expected = [[3, 3], [2, 3], [1, 3], [0, 3], [5, 3], [6, 3], [7, 3], [4, 2], [4, 1], [4, 0], [4, 4], [4, 5], [4, 6], [4, 7], [5, 4], [6, 5], [7, 6], [5, 2], [6, 1], [7, 0], [3, 2], [2, 1], [1, 0], [3, 4]]
        expect(((result-expected) + (expected-result))).to be_empty
      end

      it "can't move beyond r[-2, 2], r[1, 0] if grid is blocked" do
        move_grid = Grid.new
        queen = Queen.new("Q1W")
        move_grid.place(4, 3, queen)
        move_grid.place(2, 5, Pawn.new("P2B"))
        move_grid.place(5, 3, Pawn.new("P2B"))
        state = {board: move_grid}
        result = queen.moves(state)
        expected = [[3, 3], [2, 3], [1, 3], [0, 3], [5, 3], [4, 2], [4, 1], [4, 0], [4, 4], [4, 5], [4, 6], [4, 7], [5, 4], [6, 5], [7, 6], [5, 2], [6, 1], [7, 0], [4, 2], [3, 2], [2, 1], [1, 0], [3, 4], [2, 5]]
        expect(((result-expected) + (expected-result))).to be_empty
      end
    end

    context "when placing a king" do
      it "can move everywhere if grid is empty" do
        move_grid = Grid.new
        king = King.new("K1W")
        move_grid.place(4, 3, king)
        move_grid.place(4, 0, Pawn.new("P2W"))
        state = {board: move_grid, story: [[[7, 4], [7, 4], nil], [[7, 0], [7, 0], nil], [[7, 7], [7, 7], nil]]}
        result = king.moves(state)
        expected = [[3, 3], [3, 4], [4, 4], [5, 4], [5, 3], [5, 2], [4, 2], [3, 2]]
        expect(((result-expected) + (expected-result))).to be_empty
      end

      it "can't move beyond r[-1, 1] if grid is blocked" do
        move_grid = Grid.new
        king = King.new("K1W")
        move_grid.place(4, 3, king)
        move_grid.place(3, 4, Pawn.new("P2B"))
        state = {board: move_grid, story: [[[7, 4], [7, 4], nil], [[7, 0], [7, 0], nil], [[7, 7], [7, 7], nil]]}
        result = king.moves(state)
        expected = [[3, 3], [3, 4], [4, 4], [5, 4], [5, 3], [5, 2], [4, 2], [3, 2]]
        expect(((result-expected) + (expected-result))).to be_empty
      end

      it "can't move to r[-1, 1] if grid is occupied by same color" do
        move_grid = Grid.new
        king = King.new("K1W")
        move_grid.place(4, 3, king)
        move_grid.place(3, 4, Pawn.new("P2W"))
        state = {board: move_grid, story: [[[7, 4], [7, 4], nil], [[7, 0], [7, 0], nil], [[7, 7], [7, 7], nil]]}
        result = king.moves(state)
        expected = [[3, 3], [4, 4], [5, 4], [5, 3], [5, 2], [4, 2], [3, 2]]
        expect(((result-expected) + (expected-result))).to be_empty
      end

      it "can't move beyond to r[-1, 1], r[1, -1] if grid is blocked" do
        move_grid = Grid.new
        king = King.new("K1W")
        move_grid.place(4, 3, king)
        move_grid.place(3, 4, Pawn.new("P2W"))
        move_grid.place(5, 2, Pawn.new("P2W"))
        state = {board: move_grid, story: [[[7, 4], [7, 4], nil], [[7, 0], [7, 0], nil], [[7, 7], [7, 7], nil]]}
        result = king.moves(state)
        expected = [[3, 3], [4, 4], [5, 4], [5, 3], [4, 2], [3, 2]]
        expect(((result-expected) + (expected-result))).to be_empty
      end

      it "can castle if conditions are met" do
        move_grid = Grid.new
        king = King.new("K1W")
        left_rook = Rook.new("R1W")
        right_rook = Rook.new("R2W")
        move_grid.place(7, 4, king)
        move_grid.place(7, 0, left_rook)
        move_grid.place(7, 7, right_rook)
        state = {board: move_grid, story: []}
        result = king.moves(state)
        expected = [[6, 4], [6, 3], [6, 5], [7, 3], [7, 5], [7, 2], [7, 6]]
        expect(((result-expected) + (expected-result))).to be_empty
      end

      it "can't castle if rook moved" do
        move_grid = Grid.new
        king = King.new("K1W")
        left_rook = Rook.new("R1W")
        right_rook = Rook.new("R2W")
        move_grid.place(7, 4, king)
        move_grid.place(7, 0, left_rook)
        move_grid.place(7, 7, right_rook)
        state = {board: move_grid, story: [[[7, 0], [7, 0], nil]]}
        result = king.moves(state)
        expected = [[6, 4], [6, 3], [6, 5], [7, 3], [7, 5], [7, 6]]
        expect(((result-expected) + (expected-result))).to be_empty
      end

      it "can't castle if king moved" do
        move_grid = Grid.new
        king = King.new("K1W")
        left_rook = Rook.new("R1W")
        right_rook = Rook.new("R2W")
        move_grid.place(7, 4, king)
        move_grid.place(7, 0, left_rook)
        move_grid.place(7, 7, right_rook)
        state = {board: move_grid, story: [[[7, 4], [7, 4], nil]]}
        result = king.moves(state)
        expected = [[6, 4], [6, 3], [6, 5], [7, 3], [7, 5],]
        expect(((result-expected) + (expected-result))).to be_empty
      end

      it "can't castle if in check" do
        move_grid = Grid.new
        king = King.new("K1W")
        left_rook = Rook.new("R1W")
        right_rook = Rook.new("R2W")
        move_grid.place(7, 4, king)
        move_grid.place(7, 0, left_rook)
        move_grid.place(7, 7, right_rook)
        move_grid.place(0, 4, Rook.new("R1B"))
        state = {board: move_grid, story: []}
        result = king.moves(state)
        expected = [[6, 4], [6, 3], [6, 5], [7, 3], [7, 5],]
        expect(((result-expected) + (expected-result))).to be_empty
      end

      it "can't castle if piece in the way" do
        move_grid = Grid.new
        king = King.new("K1W")
        left_rook = Rook.new("R1W")
        right_rook = Rook.new("R2W")
        move_grid.place(7, 4, king)
        move_grid.place(7, 0, left_rook)
        move_grid.place(7, 7, right_rook)
        move_grid.place(7, 2, Bishop.new("B1B"))
        state = {board: move_grid, story: []}
        result = king.moves(state)
        expected = [[6, 4], [6, 3], [6, 5], [7, 3], [7, 5], [7, 6]]
        expect(((result-expected) + (expected-result))).to be_empty
      end

      it "can't castle if piece in the way of same color" do
        move_grid = Grid.new
        king = King.new("K1W")
        left_rook = Rook.new("R1W")
        right_rook = Rook.new("R2W")
        move_grid.place(7, 4, king)
        move_grid.place(7, 0, left_rook)
        move_grid.place(7, 7, right_rook)
        move_grid.place(7, 2, Bishop.new("B1W"))
        state = {board: move_grid, story: []}
        result = king.moves(state)
        expected = [[6, 4], [6, 3], [6, 5], [7, 3], [7, 5], [7, 6]]
        expect(((result-expected) + (expected-result))).to be_empty
      end

      it "can't castle if piece attacking path" do
        move_grid = Grid.new
        king = King.new("K1W")
        left_rook = Rook.new("R1W")
        right_rook = Rook.new("R2W")
        move_grid.place(7, 4, king)
        move_grid.place(7, 0, left_rook)
        move_grid.place(7, 7, right_rook)
        move_grid.place(0, 2, Rook.new("R1B"))
        state = {board: move_grid, story: []}
        result = king.moves(state)
        expected = [[6, 4], [6, 3], [6, 5], [7, 3], [7, 5], [7, 6]]
        expect(((result-expected) + (expected-result))).to be_empty
      end
    end
  end
end
