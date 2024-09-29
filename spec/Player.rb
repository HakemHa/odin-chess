require_relative "./Grid_Pieces"
require_relative "../lib/Player"

describe "Player" do
  describe "#play" do
    bogey_input = "k"
    context "when coords length is 1" do
      it "changes piece when input is left arrow" do
        player = Player.new
        moves = [[0, 7], [1, 4], [5, 6]]
        curr_index = 0
        coords = [moves[curr_index]]
        inputs = [bogey_input, "\e[D"]
        allow(STDIN).to receive(:getch).and_return(*inputs)
        result = player.play(coords, curr_index, moves)
        expected = [moves[(curr_index-1+moves.length)%moves.length]]
        expect(result).to eq(expected)
      end

      it "changes piece when input is up arrow" do
        player = Player.new
        moves = [[0, 7], [1, 4], [5, 6]]
        curr_index = 2
        coords = [moves[curr_index]]
        inputs = [bogey_input, "\e[A"]
        allow(STDIN).to receive(:getch).and_return(*inputs)
        result = player.play(coords, curr_index, moves)
        expected = [moves[(curr_index+1)%moves.length]]
        expect(result).to eq(expected)
      end

      it "changes piece when input is right arrow" do
        player = Player.new
        moves = [[0, 7], [1, 4], [5, 6]]
        curr_index = 1
        coords = [moves[curr_index]]
        inputs = [bogey_input, "\e[C"]
        allow(STDIN).to receive(:getch).and_return(*inputs)
        result = player.play(coords, curr_index, moves)
        expected = [moves[(curr_index+1)%moves.length]]
        expect(result).to eq(expected)
      end

      it "changes piece when input is down arrow" do
        player = Player.new
        moves = [[0, 7], [1, 4], [5, 6]]
        curr_index = 2
        coords = [moves[curr_index]]
        inputs = [bogey_input, "\e[B"]
        allow(STDIN).to receive(:getch).and_return(*inputs)
        result = player.play(coords, curr_index, moves)
        expected = [moves[(curr_index-1+moves.length)%moves.length]]
        expect(result).to eq(expected)
      end

      it "submits when input is space bar" do
        player = Player.new
        moves = [[0, 7], [1, 4], [5, 6]]
        curr_index = 0
        coords = [moves[curr_index]]
        inputs = [bogey_input, " "]
        allow(STDIN).to receive(:getch).and_return(*inputs)
        result = player.play(coords, curr_index, moves)
        expected = [moves[curr_index], "."]
        expect(result).to eq(expected)
      end

      it "submits when input is enter key" do
        player = Player.new
        moves = [[0, 7], [1, 4], [5, 6]]
        curr_index = 0
        coords = [moves[curr_index]]
        inputs = [bogey_input, "\r"]
        allow(STDIN).to receive(:getch).and_return(*inputs)
        result = player.play(coords, curr_index, moves)
        expected = [moves[curr_index], "."]
        expect(result).to eq(expected)
      end

      it "does nothing when input is backspace" do
        player = Player.new
        moves = [[0, 7], [1, 4], [5, 6]]
        curr_index = 0
        coords = [moves[curr_index]]
        inputs = [bogey_input, "\u007F"]
        allow(STDIN).to receive(:getch).and_return(*inputs)
        result = player.play(coords, curr_index, moves)
        expected = [moves[curr_index]]
        expect(result).to eq(expected)
      end

      it "exits when input is e key" do
        player = Player.new
        moves = [[0, 7], [1, 4], [5, 6]]
        curr_index = 0
        coords = [moves[curr_index]]
        inputs = [bogey_input, "e"]
        allow(STDIN).to receive(:getch).and_return(*inputs)
        result = player.play(coords, curr_index, moves)
        expected = ["e"]
        expect(result).to eq(expected)
      end

      it "exits when input is q key" do
        player = Player.new
        moves = [[0, 7], [1, 4], [5, 6]]
        curr_index = 0
        coords = [moves[curr_index]]
        inputs = [bogey_input, "q"]
        allow(STDIN).to receive(:getch).and_return(*inputs)
        result = player.play(coords, curr_index, moves)
        expected = ["e"]
        expect(result).to eq(expected)
      end

      it "hard exits when input is Ctrl+C" do
        player = Player.new
        moves = [[0, 7], [1, 4], [5, 6]]
        curr_index = 0
        coords = [moves[curr_index]]
        inputs = [bogey_input, "\u0003"]
        allow(STDIN).to receive(:getch).and_return(*inputs)
        result = player.play(coords, curr_index, moves)
        expected = ["fe"]
        expect(result).to eq(expected)
      end
    end

    context "when coords length is 2" do
      it "changes move when input is left arrow" do
        player = Player.new
        moves = [[0, 7], [1, 4], [5, 6]]
        curr_index = 0
        coords = [[1, 2], moves[curr_index]]
        inputs = [bogey_input, "\e[D"]
        allow(STDIN).to receive(:getch).and_return(*inputs)
        result = player.play(coords, curr_index, moves)
        expected = [[1, 2], moves[(curr_index-1+moves.length)%moves.length]]
        expect(result).to eq(expected)
      end

      it "changes move when input is up arrow" do
        player = Player.new
        moves = [[0, 7], [1, 4], [5, 6]]
        curr_index = 2
        coords = [[1, 2], moves[curr_index]]
        inputs = [bogey_input, "\e[A"]
        allow(STDIN).to receive(:getch).and_return(*inputs)
        result = player.play(coords, curr_index, moves)
        expected = [[1, 2], moves[(curr_index+1)%moves.length]]
        expect(result).to eq(expected)
      end

      it "changes move when input is right arrow" do
        player = Player.new
        moves = [[0, 7], [1, 4], [5, 6]]
        curr_index = 1
        coords = [[1, 2], moves[curr_index]]
        inputs = [bogey_input, "\e[C"]
        allow(STDIN).to receive(:getch).and_return(*inputs)
        result = player.play(coords, curr_index, moves)
        expected = [[1, 2], moves[(curr_index+1)%moves.length]]
        expect(result).to eq(expected)
      end

      it "changes move when input is down arrow" do
        player = Player.new
        moves = [[0, 7], [1, 4], [5, 6]]
        curr_index = 2
        coords = [[1, 2], moves[curr_index]]
        inputs = [bogey_input, "\e[B"]
        allow(STDIN).to receive(:getch).and_return(*inputs)
        result = player.play(coords, curr_index, moves)
        expected = [[1, 2], moves[(curr_index-1+moves.length)%moves.length]]
        expect(result).to eq(expected)
      end

      it "submits when input is space bar" do
        player = Player.new
        moves = [[0, 7], [1, 4], [5, 6]]
        curr_index = 0
        coords = [[1, 2], moves[curr_index]]
        inputs = [bogey_input, " "]
        allow(STDIN).to receive(:getch).and_return(*inputs)
        result = player.play(coords, curr_index, moves)
        expected = [[1, 2], moves[curr_index], "."]
        expect(result).to eq(expected)
      end

      it "submits when input is enter key" do
        player = Player.new
        moves = [[0, 7], [1, 4], [5, 6]]
        curr_index = 0
        coords = [[1, 2], moves[curr_index]]
        inputs = [bogey_input, "\r"]
        allow(STDIN).to receive(:getch).and_return(*inputs)
        result = player.play(coords, curr_index, moves)
        expected = [[1, 2], moves[curr_index], "."]
        expect(result).to eq(expected)
      end

      it "resets when input is backspace" do
        player = Player.new
        moves = [[0, 7], [1, 4], [5, 6]]
        curr_index = 0
        coords = [[1, 2], moves[curr_index]]
        inputs = [bogey_input, "\u007F"]
        allow(STDIN).to receive(:getch).and_return(*inputs)
        result = player.play(coords, curr_index, moves)
        expected = [[1, 2]]
        expect(result).to eq(expected)
      end

      it "exits when input is e key" do
        player = Player.new
        moves = [[0, 7], [1, 4], [5, 6]]
        curr_index = 0
        coords = [[1, 2], moves[curr_index]]
        inputs = [bogey_input, "e"]
        allow(STDIN).to receive(:getch).and_return(*inputs)
        result = player.play(coords, curr_index, moves)
        expected = ["e"]
        expect(result).to eq(expected)
      end

      it "exits when input is q key" do
        player = Player.new
        moves = [[0, 7], [1, 4], [5, 6]]
        curr_index = 0
        coords = [[1, 2], moves[curr_index]]
        inputs = [bogey_input, "q"]
        allow(STDIN).to receive(:getch).and_return(*inputs)
        result = player.play(coords, curr_index, moves)
        expected = ["e"]
        expect(result).to eq(expected)
      end

      it "hard exits when input is Ctrl+C" do
        player = Player.new
        moves = [[0, 7], [1, 4], [5, 6]]
        curr_index = 0
        coords = [[1, 2], moves[curr_index]]
        inputs = [bogey_input, "\u0003"]
        allow(STDIN).to receive(:getch).and_return(*inputs)
        result = player.play(coords, curr_index, moves)
        expected = ["fe"]
        expect(result).to eq(expected)
      end
    end
  end
end