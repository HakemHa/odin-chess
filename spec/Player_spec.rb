Dir[File.join(__dir__, '../lib/pieces', "*")].each { |file| require file }
require_relative "../lib/Grid"
require_relative "../lib/Player"

describe "Player" do
  describe "#handle_input" do
    def act(input)
      case input
      when "submit"
        return "."
      when "up"
        return +1
      else
        nil
      end
    end
    context "when receiving invalid input" do
      it "waits for valid input" do
        inputs = [" ", "k"]
        allow(STDIN).to receive(:getch).and_wrap_original do |original, *args|
          sleep(0.1)
          next inputs.pop
        end
        result = Player.handle_input(method(:act))
        expected = "."
        expect(result).to eq(expected)
      end

      it "waits for valid input (long input)" do
        inputs = ["\e[A", "kkk"]
        allow(STDIN).to receive(:getch).and_wrap_original do |original, *args|
          sleep(0.1)
          next inputs.pop
        end
        result = Player.handle_input(method(:act))
        expected = +1
        expect(result).to eq(expected)
      end
    end

    context "when receiving not acted on input" do
      it "waits for valid input" do
        inputs = [" ", "\r"]
        allow(STDIN).to receive(:getch).and_wrap_original do |original, *args|
          sleep(0.1)
          next inputs.pop
        end
        result = Player.handle_input(method(:act))
        expected = "."
        expect(result).to eq(expected)
      end

      it "waits for valid input (long input)" do
        inputs = ["\e[A", "\e[B"]
        allow(STDIN).to receive(:getch).and_wrap_original do |original, *args|
          sleep(0.1)
          next inputs.pop
        end
        result = Player.handle_input(method(:act))
        expected = +1
        expect(result).to eq(expected)
      end
    end

    context "when receiving acted on input" do
      it "returns valid input" do
        inputs = [" "]
        allow(STDIN).to receive(:getch).and_wrap_original do |original, *args|
          sleep(0.1)
          next inputs.pop
        end
        result = Player.handle_input(method(:act))
        expected = "."
        expect(result).to eq(expected)
      end

      it "returns valid input (long input)" do
        inputs = ["\e[A"]
        allow(STDIN).to receive(:getch).and_wrap_original do |original, *args|
          sleep(0.1)
          next inputs.pop
        end
        result = Player.handle_input(method(:act))
        expected = +1
        expect(result).to eq(expected)
      end
    end

    context "when trying to exit" do
      it "exits at e" do
        inputs = [" ", "e"]
        allow(STDIN).to receive(:getch).and_wrap_original do |original, *args|
          sleep(0.1)
          next inputs.pop
        end
        result = Player.handle_input(method(:act))
        expected = "e"
        expect(result).to eq(expected)
      end

      it "exits at fe" do
        inputs = [" ", "\u0003"]
        allow(STDIN).to receive(:getch).and_wrap_original do |original, *args|
          sleep(0.1)
          next inputs.pop
        end
        result = Player.handle_input(method(:act))
        expected = "fe"
        expect(result).to eq(expected)
      end
    end
  end
end