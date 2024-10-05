require_relative "./Grid_Pieces"
require_relative "../lib/Player"

describe "Player" do
  describe "#play" do
    bogey_input = "k"
    context "when coords length is 1" do
      it "changes piece when input is left arrow" do
        moves_length = 3
        curr_index = 0
        inputs = [bogey_input, "\e[D"]
        input_index = -1
        allow(STDIN).to receive(:getch).and_wrap_original do |original_method|
          sleep(0.05)
          input_index += 1
          if input_index < inputs.length then
            inputs[input_index]
          end
        end
        result = Player.play(curr_index, moves_length)
        expected = (curr_index-1+moves_length)%moves_length
        expect(result).to eq(expected)
      end

      it "changes piece when input is up arrow" do
        moves_length = 3
        curr_index = 2
        inputs = [bogey_input, "\e[A"]
        input_index = -1
        allow(STDIN).to receive(:getch).and_wrap_original do |original_method|
          sleep(0.05)
          input_index += 1
          if input_index < inputs.length then
            inputs[input_index]
          end
        end
        result = Player.play(curr_index, moves_length)
        expected = (curr_index+1)%moves_length
        expect(result).to eq(expected)
      end

      it "changes piece when input is right arrow" do
        moves_length = 3
        curr_index = 1
        inputs = [bogey_input, "\e[C"]
        input_index = -1
        allow(STDIN).to receive(:getch).and_wrap_original do |original_method|
          sleep(0.05)
          input_index += 1
          if input_index < inputs.length then
            inputs[input_index]
          end
        end
        result = Player.play(curr_index, moves_length)
        expected = (curr_index+1)%moves_length
        expect(result).to eq(expected)
      end

      it "changes piece when input is down arrow" do
        moves_length = 3
        curr_index = 2
        inputs = [bogey_input, "\e[B"]
        input_index = -1
        allow(STDIN).to receive(:getch).and_wrap_original do |original_method|
          sleep(0.05)
          input_index += 1
          if input_index < inputs.length then
            inputs[input_index]
          end
        end
        result = Player.play(curr_index, moves_length)
        expected = (curr_index-1+moves_length)%moves_length
        expect(result).to eq(expected)
      end

      it "submits when input is space bar" do
        moves_length = 3
        curr_index = 0
        inputs = [bogey_input, " "]
        input_index = -1
        allow(STDIN).to receive(:getch).and_wrap_original do |original_method|
          sleep(0.05)
          input_index += 1
          if input_index < inputs.length then
            inputs[input_index]
          end
        end
        result = Player.play(curr_index, moves_length)
        expected = "."
        expect(result).to eq(expected)
      end

      it "submits when input is enter key" do
        moves_length = 3
        curr_index = 0
        inputs = [bogey_input, "\r"]
        input_index = -1
        allow(STDIN).to receive(:getch).and_wrap_original do |original_method|
          sleep(0.05)
          input_index += 1
          if input_index < inputs.length then
            inputs[input_index]
          end
        end
        result = Player.play(curr_index, moves_length)
        expected = "."
        expect(result).to eq(expected)
      end

      it "does nothing when input is backspace" do
        moves_length = 3
        curr_index = 0
        inputs = [bogey_input, "\u007f"]
        input_index = -1
        allow(STDIN).to receive(:getch).and_wrap_original do |original_method|
          sleep(0.05)
          input_index += 1
          if input_index < inputs.length then
            inputs[input_index]
          end
        end
        result = Player.play(curr_index, moves_length)
        expected = "<"
        expect(result).to eq(expected)
      end

      it "exits when input is e" do
        moves_length = 3
        curr_index = 0
        inputs = [bogey_input, "e"]
        input_index = -1
        allow(STDIN).to receive(:getch).and_wrap_original do |original_method|
          sleep(0.05)
          input_index += 1
          if input_index < inputs.length then
            inputs[input_index]
          end
        end
        result = Player.play(curr_index, moves_length)
        expected = "e"
        expect(result).to eq(expected)
      end

      it "exits when input is q key" do
        moves_length = 3
        curr_index = 0
        inputs = [bogey_input, "q"]
        input_index = -1
        allow(STDIN).to receive(:getch).and_wrap_original do |original_method|
          sleep(0.05)
          input_index += 1
          if input_index < inputs.length then
            inputs[input_index]
          end
        end
        result = Player.play(curr_index, moves_length)
        expected = "e"
        expect(result).to eq(expected)
      end

      it "hard exits when input is Ctrl+C" do
        moves_length = 3
        curr_index = 0
        inputs = [bogey_input, "\u0003"]
        input_index = -1
        allow(STDIN).to receive(:getch).and_wrap_original do |original_method|
          sleep(0.05)
          input_index += 1
          if input_index < inputs.length then
            inputs[input_index]
          end
        end
        result = Player.play(curr_index, moves_length)
        expected = "fe"
        expect(result).to eq(expected)
      end
    end
  end
end