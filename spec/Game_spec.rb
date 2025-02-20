require 'set'
require_relative "../lib/Game"

def system(*not_important)
  nil
end

# Tests for game
# Test play_game
#    Test move50
#    Test threefold
#    Test stalemate
#    Test mutual
#    Test Castling
#    Test en passant
#    Test fast checkmates
#    Test Veselin vs. Kapsarov (1999)
# Test Settings
# Test exit (when saying no)

describe Game do
  DOT = "."
  EXIT = "e"
  M = {
    a8: [0, 0],
    b8: [0, 1],
    c8: [0, 2],
    d8: [0, 3],
    e8: [0, 4],
    f8: [0, 5],
    g8: [0, 6],
    h8: [0, 7],
    a7: [1, 0],
    b7: [1, 1],
    c7: [1, 2],
    d7: [1, 3],
    e7: [1, 4],
    f7: [1, 5],
    g7: [1, 6],
    h7: [1, 7],
    a6: [2, 0],
    b6: [2, 1],
    c6: [2, 2],
    d6: [2, 3],
    e6: [2, 4],
    f6: [2, 5],
    g6: [2, 6],
    h6: [2, 7],
    a5: [3, 0],
    b5: [3, 1],
    c5: [3, 2],
    d5: [3, 3],
    e5: [3, 4],
    f5: [3, 5],
    g5: [3, 6],
    h5: [3, 7],
    a4: [4, 0],
    b4: [4, 1],
    c4: [4, 2],
    d4: [4, 3],
    e4: [4, 4],
    f4: [4, 5],
    g4: [4, 6],
    h4: [4, 7],
    a3: [5, 0],
    b3: [5, 1],
    c3: [5, 2],
    d3: [5, 3],
    e3: [5, 4],
    f3: [5, 5],
    g3: [5, 6],
    h3: [5, 7],
    a2: [6, 0],
    b2: [6, 1],
    c2: [6, 2],
    d2: [6, 3],
    e2: [6, 4],
    f2: [6, 5],
    g2: [6, 6],
    h2: [6, 7],
    a1: [7, 0],
    b1: [7, 1],
    c1: [7, 2],
    d1: [7, 3],
    e1: [7, 4],
    f1: [7, 5],
    g1: [7, 6],
    h1: [7, 7]
  }

  context "when getting draw" do
    it "draws at 50 times" do
      game_state = {}
      Game.create_game_state(game_state)
      50.times do
        game_state[:story].push([nil, nil, nil])
      end
      result = Game.move50?(game_state)
      expected = true
      expect(result).to eq(expected)
    end

    it "doesn't draws at 50 times if enemy was eaten" do
      game_state = {}
      Game.create_game_state(game_state)
      50.times do
        game_state[:story].push([nil, nil, nil])
      end
      game_state[:story][rand(50).floor][2] = Pawn.new("P1W")
      result = Game.move50?(game_state)
      expected = false
      expect(result).to eq(expected)
    end

    it "draws after moving threefold" do
      game_state = {}
      Game.create_game_state(game_state)
      game_state[:story].push([0, 0, nil])
      game_state[:story].push([2, 2, nil])
      game_state[:story].push([1, 1, nil])
      game_state[:story].push([3, 3, nil])
      game_state[:story].push([0, 0, nil])
      game_state[:story].push([2, 2, nil])
      result = Game.threefold?(game_state)
      expected = true
      expect(result).to eq(expected)
    end

    it "doesn't draw if one of the colors progressed" do
      game_state = {}
      Game.create_game_state(game_state)
      game_state[:story].push([0, 0, nil])
      game_state[:story].push([2, 2, nil])
      game_state[:story].push([1, 1, nil])
      game_state[:story].push([4, 3, nil])
      game_state[:story].push([0, 0, nil])
      game_state[:story].push([2, 2, nil])
      result = Game.threefold?(game_state)
      expected = true
      expect(result).to eq(expected)
    end
  
    it "draws at stalemate" do
      game_state = {}
      Game.create_game_state(game_state)
      game_state[:turn] = 1
      staleBoard = Grid.new
      staleBoard.place(1, 7, Pawn.new("P1B"))
      staleBoard.place(2, 7, King.new("K1B"))
      staleBoard.place(3, 7, Bishop.new("B1W"))
      staleBoard.place(4, 6, King.new("K1W"))
      staleBoard.place(4, 3, Queen.new("Q1W"))
      game_state[:board] = staleBoard
      result = Game.stalemate?(game_state)
      expected = true
      expect(result).to eq(expected)
    end

    it "doesn't stalemate if checkmate" do
      game_state = {}
      Game.create_game_state(game_state)
      game_state[:turn] = 1
      staleBoard = Grid.new
      staleBoard.place(1, 7, Pawn.new("P1B"))
      staleBoard.place(2, 7, King.new("K1B"))
      staleBoard.place(3, 7, Bishop.new("B1W"))
      staleBoard.place(4, 6, King.new("K1W"))
      staleBoard.place(3, 6, Queen.new("Q1W"))
      game_state[:board] = staleBoard
      result = Game.stalemate?(game_state)
      expected = false
      expect(result).to eq(expected)
    end
  end

  context "when trying to castle" do
    it "moves king and rook" do
      plays = [
        [M[:e2], M[:e4]],
        [M[:b8], M[:a6]],
        [M[:d2], M[:d4]],
        [M[:a6], M[:b8]],
        [M[:f1], M[:c4]],
        [M[:b8], M[:a6]],
        [M[:g1], M[:f3]],
        [M[:a6], M[:b8]],
        [M[:e1], M[:g1]],
        EXIT
      ]
      play_index = 0
      allow(Game).to receive(:get_move_human).and_wrap_original do |original, *args|
        if plays[play_index].length == 2 then
          piece_location, move = plays[play_index]
          board = args[0][:board]
          piece = board.board[piece_location[0]][piece_location[1]]
          play_index += 1
          to_return = [piece, move]
        else
          to_return = "e"
        end
        next to_return
      end
      game = Game.new("fe")
      game_state = game.instance_variable_get(:@game_state)
      settings_state = game.instance_variable_get(:@settings_state)
      settings_state[:render] = false
      Game.play_game(game_state, settings_state)
      board = game_state[:board]
      result = [board.get_location("K1W"), board.get_location("R2W")]
      expected = [M[:g1], M[:f1]]
      expect(result).to eq(expected)
    end
  end

  context "when trying to en passant" do
    it "eats passing pawn" do
      game = Game.new("fe")
      plays = [
        [M[:e2], M[:e4]],
        [M[:a7], M[:a6]],
        [M[:e4], M[:e5]],
        [M[:d7], M[:d5]],
        [M[:e5], M[:d6]],
        EXIT
      ]
      play_index = 0
      allow(Game).to receive(:get_move_human).and_wrap_original do |original, *args|
        if plays[play_index].length == 2 then
          piece_location, move = plays[play_index]
          board = args[0][:board]
          piece = board.board[piece_location[0]][piece_location[1]]
          play_index += 1
          to_return = [piece, move]
        else
          to_return = "e"
        end
        next to_return
      end
      game_state = game.instance_variable_get(:@game_state)
      settings_state = game.instance_variable_get(:@settings_state)
      settings_state[:render] = false
      Game.play_game(game_state, settings_state)
      board = game_state[:board]
      ate = M[:d5]
      result = board.board[ate[0]][ate[1]]
      expected = nil
      expect(result).to eq(expected)
    end
  end

  context "when turning pawn to queen" do
    it "converts pawn to queen" do
      game = Game.new("fe")
      plays = [
        [M[:h2], M[:h4]],
        [M[:g7], M[:g5]],
        [M[:h4], M[:g5]],
        [M[:g8], M[:f6]],
        [M[:g5], M[:g6]],
        [M[:h7], M[:h6]],
        [M[:g6], M[:g7]],
        [M[:h6], M[:h5]],
        [M[:g7], M[:g8]],
        EXIT
      ]
      play_index = 0
      allow(Game).to receive(:get_move_human).and_wrap_original do |original, *args|
        if plays[play_index].length == 2 then
          piece_location, move = plays[play_index]
          board = args[0][:board]
          piece = board.board[piece_location[0]][piece_location[1]]
          play_index += 1
          to_return = [piece, move]
        else
          to_return = "e"
        end
        next to_return
      end
      game_state = game.instance_variable_get(:@game_state)
      settings_state = game.instance_variable_get(:@settings_state)
      settings_state[:render] = false
      Game.play_game(game_state, settings_state)
      board = game_state[:board]
      result = board.board[0][6].id[0..1]
      expected = "Q9"
      expect(result).to eq(expected)
    end
  end

  context "when in check" do
    it "only gives possible moves (king dodge)" do
      game = Game.new("fe")
      plays = [
        ["P5W", M[:e4]],
        ["P4B", M[:d5]],
        ["P5W", M[:d5]],
        ["Q1B", M[:d5]],
        ["Q1W", M[:h5]],
        ["Q1B", M[:d4]],
        ["H2W", M[:f3]],
        ["Q1B", M[:f4]],
        ["B2W", M[:c4]],
        ["Q1B", M[:f5]],
        ["B2W", M[:e6]],
        ["Q1B", M[:e4]],
        EXIT
      ]
      play_index = 0
      allow(Game).to receive(:get_move_human).and_wrap_original do |original, *args|
        if plays[play_index].length == 2 then
          piece_id, move = plays[play_index]
          piece = nil
          args[0][:board].board.find { |r| r.find { |p| piece = p if !p.nil? && p.id == piece_id } }
          play_index += 1
          to_return = [piece, move]
        else
          to_return = "e"
        end
        next to_return
      end
      game_state = game.instance_variable_get(:@game_state)
      settings_state = game.instance_variable_get(:@settings_state)
      settings_state[:render] = false
      Game.play_game(game_state, settings_state)
      result = (Game.get_valid_moves(game_state).to_a.map { |k, v| [k.id, v.to_set] }).to_set
      expected = [["K1W", [M[:d1], M[:f1]].to_set]].to_set
      expect(result).to eq(expected)
    end

    it "only gives possible moves (king kill)" do
      game = Game.new("fe")
      plays = [
        ["P5W", M[:e4]],
        ["P5B", M[:e5]],
        ["B2W", M[:c4]],
        ["H1B", M[:c6]],
        ["P4W", M[:d3]],
        ["Q1B", M[:h4]],
        ["H2W", M[:f3]],
        ["Q1B", M[:f2]],
        EXIT
      ]
      play_index = 0
      allow(Game).to receive(:get_move_human).and_wrap_original do |original, *args|
        if plays[play_index].length == 2 then
          piece_id, move = plays[play_index]
          piece = nil
          args[0][:board].board.find { |r| r.find { |p| piece = p if !p.nil? && p.id == piece_id } }
          play_index += 1
          to_return = [piece, move]
        else
          to_return = "e"
        end
        next to_return
      end
      game_state = game.instance_variable_get(:@game_state)
      settings_state = game.instance_variable_get(:@settings_state)
      settings_state[:render] = false
      Game.play_game(game_state, settings_state)
      result = (Game.get_valid_moves(game_state).to_a.map { |k, v| [k.id, v.to_set] }).to_set
      expected = [["K1W", [M[:f2]].to_set]].to_set
      expect(result).to eq(expected)
    end
    
    it "only gives possible moves (piece kill)" do
      game = Game.new("fe")
      plays = [
        ["P5W", M[:e4]],
        ["P4B", M[:d5]],
        ["H1W", M[:c3]],
        ["P4B", M[:e4]],
        ["H1W", M[:e4]],
        ["H2B", M[:f6]],
        ["P4W", M[:d4]],
        ["P3B", M[:c6]],
        ["Q1W", M[:e2]],
        ["H1B", M[:d7]],
        ["Q1W", M[:f3]],
        ["P8B", M[:h6]],
        ["H1W", M[:d6]],
        EXIT
      ]
      play_index = 0
      allow(Game).to receive(:get_move_human).and_wrap_original do |original, *args|
        if plays[play_index].length == 2 then
          piece_id, move = plays[play_index]
          piece = nil
          args[0][:board].board.find { |r| r.find { |p| piece = p if !p.nil? && p.id == piece_id } }
          play_index += 1
          to_return = [piece, move]
        else
          to_return = "e"
        end
        next to_return
      end
      game_state = game.instance_variable_get(:@game_state)
      settings_state = game.instance_variable_get(:@settings_state)
      settings_state[:render] = false
      Game.play_game(game_state, settings_state)
      result = (Game.get_valid_moves(game_state).to_a.map { |k, v| [k.id, v.to_set] }).to_set
      expected = [["P5B", [M[:d6]].to_set]].to_set
      expect(result).to eq(expected)
    end

    it "only gives possible moves (piece block)" do
      game = Game.new("fe")
      plays = [
        ["P5W", M[:e4]],
        ["P5B", M[:e6]],
        ["P4W", M[:d4]],
        ["P4B", M[:d6]],
        ["B1W", M[:g5]],
        ["Q1B", M[:g5]],
        ["P6W", M[:f4]],
        ["Q1B", M[:f4]],
        ["P1W", M[:a3]],
        ["Q1B", M[:e3]],
        EXIT
      ]
      play_index = 0
      allow(Game).to receive(:get_move_human).and_wrap_original do |original, *args|
        if plays[play_index].length == 2 then
          piece_id, move = plays[play_index]
          piece = nil
          args[0][:board].board.find { |r| r.find { |p| piece = p if !p.nil? && p.id == piece_id } }
          play_index += 1
          to_return = [piece, move]
        else
          to_return = "e"
        end
        next to_return
      end
      game_state = game.instance_variable_get(:@game_state)
      settings_state = game.instance_variable_get(:@settings_state)
      settings_state[:render] = false
      Game.play_game(game_state, settings_state)
      result = (Game.get_valid_moves(game_state).to_a.map { |k, v| [k.id, v.to_set] }).to_set
      expected = [["Q1W", [M[:e2]].to_set], ["B2W", [M[:e2]].to_set], ["H2W", [M[:e2]].to_set]].to_set
      expect(result).to eq(expected)
    end
  end

  context "when getting quickly checkmated" do
    it "in fool's mate" do
      game = Game.new("fe")
      plays = [
        ["P6W", M[:f3]],
        ["P5B", M[:e5]],
        ["P7W", M[:g4]],
        ["Q1B", M[:h4]],
        EXIT
      ]
      play_index = 0
      allow(Game).to receive(:get_move_human).and_wrap_original do |original, *args|
        if plays[play_index].length == 2 then
          piece_id, move = plays[play_index]
          piece = nil
          args[0][:board].board.find { |r| r.find { |p| piece = p if !p.nil? && p.id == piece_id } }
          play_index += 1
          to_return = [piece, move]
        else
          to_return = "e"
        end
        next to_return
      end
      game_state = game.instance_variable_get(:@game_state)
      settings_state = game.instance_variable_get(:@settings_state)
      settings_state[:render] = false
      result = Game.play_game(game_state, settings_state)
      expected = "end"
      expect(result).to eq(expected)
    end

    it "in grob's attack" do
      game = Game.new("fe")
      plays = [
        ["P7W", M[:g4]],
        ["P5B", M[:e5]],
        ["P6W", M[:f4]],
        ["Q1B", M[:h4]],
        EXIT
      ]
      play_index = 0
      allow(Game).to receive(:get_move_human).and_wrap_original do |original, *args|
        if plays[play_index].length == 2 then
          piece_id, move = plays[play_index]
          piece = nil
          args[0][:board].board.find { |r| r.find { |p| piece = p if !p.nil? && p.id == piece_id } }
          play_index += 1
          to_return = [piece, move]
        else
          to_return = "e"
        end
        next to_return
      end
      game_state = game.instance_variable_get(:@game_state)
      settings_state = game.instance_variable_get(:@settings_state)
      settings_state[:render] = false
      result = Game.play_game(game_state, settings_state)
      expected = "end"
      expect(result).to eq(expected)
    end

    it "in scholar's mate" do
      game = Game.new("fe")
      plays = [
        ["P5W", M[:e4]],
        ["P5B", M[:e5]],
        ["B2W", M[:c4]],
        ["H1B", M[:c6]],
        ["Q1W", M[:h5]],
        ["H2B", M[:f6]],
        ["Q1W", M[:f7]],
        EXIT
      ]
      play_index = 0
      allow(Game).to receive(:get_move_human).and_wrap_original do |original, *args|
        if plays[play_index].length == 2 then
          piece_id, move = plays[play_index]
          piece = nil
          args[0][:board].board.find { |r| r.find { |p| piece = p if !p.nil? && p.id == piece_id } }
          play_index += 1
          to_return = [piece, move]
        else
          to_return = "e"
        end
        next to_return
      end
      game_state = game.instance_variable_get(:@game_state)
      settings_state = game.instance_variable_get(:@settings_state)
      settings_state[:render] = false
      result = Game.play_game(game_state, settings_state)
      expected = "end"
      expect(result).to eq(expected)
    end

    it "in dutch defense" do
      game = Game.new("fe")
      plays = [
        ["P4W", M[:d4]],
        ["P6B", M[:f5]],
        ["B1W", M[:g5]],
        ["P8B", M[:h6]],
        ["B1W", M[:h4]],
        ["P7B", M[:g5]],
        ["P5W", M[:e4]],
        ["P7B", M[:h4]],
        ["Q1W", M[:h5]],
        EXIT
      ]
      play_index = 0
      allow(Game).to receive(:get_move_human).and_wrap_original do |original, *args|
        if plays[play_index].length == 2 then
          piece_id, move = plays[play_index]
          piece = nil
          args[0][:board].board.find { |r| r.find { |p| piece = p if !p.nil? && p.id == piece_id } }
          play_index += 1
          to_return = [piece, move]
        else
          to_return = "e"
        end
        next to_return
      end
      game_state = game.instance_variable_get(:@game_state)
      settings_state = game.instance_variable_get(:@settings_state)
      settings_state[:render] = false
      result = Game.play_game(game_state, settings_state)
      expected = "end"
      expect(result).to eq(expected)
    end
    it "in bird's opening" do
      game = Game.new("fe")
      plays = [
        ["P6W", M[:f4]],
        ["P5B", M[:e5]],
        ["P6W", M[:e5]],
        ["P4B", M[:d6]],
        ["P6W", M[:d6]],
        ["B2B", M[:d6]],
        ["H1W", M[:c3]],
        ["Q1B", M[:h4]],
        ["P7W", M[:g3]],
        ["Q1B", M[:g3]],
        ["P8W", M[:g3]],
        ["B2B", M[:g3]],
        EXIT
      ]
      play_index = 0
      allow(Game).to receive(:get_move_human).and_wrap_original do |original, *args|
        if plays[play_index].length == 2 then
          piece_id, move = plays[play_index]
          piece = nil
          args[0][:board].board.find { |r| r.find { |p| piece = p if !p.nil? && p.id == piece_id } }
          play_index += 1
          to_return = [piece, move]
        else
          to_return = "e"
        end
        next to_return
      end
      game_state = game.instance_variable_get(:@game_state)
      settings_state = game.instance_variable_get(:@settings_state)
      settings_state[:render] = false
      result = Game.play_game(game_state, settings_state)
      expected = "end"
      expect(result).to eq(expected)
    end
    it "in caro-kann defense" do
      game = Game.new("fe")
      plays = [
        ["P5W", M[:e4]],
        ["P3B", M[:c6]],
        ["P4W", M[:d4]],
        ["P4B", M[:d5]],
        ["H1W", M[:c3]],
        ["P4B", M[:e4]],
        ["H1W", M[:e4]],
        ["H1B", M[:d7]],
        ["Q1W", M[:e2]],
        ["H2B", M[:f6]],
        ["H1W", M[:d6]],
        EXIT
      ]
      play_index = 0
      allow(Game).to receive(:get_move_human).and_wrap_original do |original, *args|
        if plays[play_index].length == 2 then
          piece_id, move = plays[play_index]
          piece = nil
          args[0][:board].board.find { |r| r.find { |p| piece = p if !p.nil? && p.id == piece_id } }
          play_index += 1
          to_return = [piece, move]
        else
          to_return = "e"
        end
        next to_return
      end
      game_state = game.instance_variable_get(:@game_state)
      settings_state = game.instance_variable_get(:@settings_state)
      settings_state[:render] = false
      result = Game.play_game(game_state, settings_state)
      expected = "end"
      expect(result).to eq(expected)
    end
    it "in italian game" do
      game = Game.new("fe")
      plays = [
        ["P5W", M[:e4]],
        ["P5B", M[:e5]],
        ["H2W", M[:f3]],
        ["H1B", M[:c6]],
        ["B2W", M[:c4]],
        ["H1B", M[:d4]],
        ["H2W", M[:e5]],
        ["Q1B", M[:g5]],
        ["H2W", M[:f7]],
        ["Q1B", M[:g2]],
        ["R2W", M[:f1]],
        ["Q1B", M[:e4]],
        ["B2W", M[:e2]],
        ["H1B", M[:f3]],
        EXIT
      ]
      play_index = 0
      allow(Game).to receive(:get_move_human).and_wrap_original do |original, *args|
        if plays[play_index].length == 2 then
          piece_id, move = plays[play_index]
          piece = nil
          args[0][:board].board.find { |r| r.find { |p| piece = p if !p.nil? && p.id == piece_id } }
          play_index += 1
          to_return = [piece, move]
        else
          to_return = "e"
        end
        next to_return
      end
      game_state = game.instance_variable_get(:@game_state)
      settings_state = game.instance_variable_get(:@settings_state)
      settings_state[:render] = false
      result = Game.play_game(game_state, settings_state)
      expected = "end"
      expect(result).to eq(expected)
    end
    it "in owen's defense" do
      game = Game.new("fe")
      plays = [
        ["P5W", M[:e4]],
        ["P2B", M[:b6]],
        ["P4W", M[:d4]],
        ["B1B", M[:b7]],
        ["B2W", M[:d3]],
        ["P6B", M[:f5]],
        ["P5W", M[:f5]],
        ["B1B", M[:g2]],
        ["Q1W", M[:h5]],
        ["P7B", M[:g6]],
        ["P5W", M[:g6]],
        ["H2B", M[:f6]],
        ["P5W", M[:h7]],
        ["H2B", M[:h5]],
        ["B2W", M[:g6]],
        EXIT
      ]
      play_index = 0
      allow(Game).to receive(:get_move_human).and_wrap_original do |original, *args|
        if plays[play_index].length == 2 then
          piece_id, move = plays[play_index]
          piece = nil
          args[0][:board].board.find { |r| r.find { |p| piece = p if !p.nil? && p.id == piece_id } }
          play_index += 1
          to_return = [piece, move]
        else
          to_return = "e"
        end
        next to_return
      end
      game_state = game.instance_variable_get(:@game_state)
      settings_state = game.instance_variable_get(:@settings_state)
      settings_state[:render] = false
      result = Game.play_game(game_state, settings_state)
      expected = "end"
      expect(result).to eq(expected)
    end
    it "in englund gambit" do
      game = Game.new("fe")
      plays = [
        ["P4W", M[:d4]],
        ["P5B", M[:e5]],
        ["P4W", M[:e5]],
        ["Q1B", M[:e7]],
        ["H2W", M[:f3]],
        ["H1B", M[:c6]],
        ["B1W", M[:f4]],
        ["Q1B", M[:b4]],
        ["B1W", M[:d2]],
        ["Q1B", M[:b2]],
        ["B1W", M[:c3]],
        ["B2B", M[:b4]],
        ["Q1W", M[:d2]],
        ["B2B", M[:c3]],
        ["Q1W", M[:c3]],
        ["Q1B", M[:c1]],
        EXIT
      ]
      play_index = 0
      allow(Game).to receive(:get_move_human).and_wrap_original do |original, *args|
        if plays[play_index].length == 2 then
          piece_id, move = plays[play_index]
          piece = nil
          args[0][:board].board.find { |r| r.find { |p| piece = p if !p.nil? && p.id == piece_id } }
          play_index += 1
          to_return = [piece, move]
        else
          to_return = "e"
        end
        next to_return
      end
      game_state = game.instance_variable_get(:@game_state)
      settings_state = game.instance_variable_get(:@settings_state)
      settings_state[:render] = false
      result = Game.play_game(game_state, settings_state)
      expected = "end"
      expect(result).to eq(expected)
    end
    it "in budapest defense" do
      game = Game.new("fe")
      plays = [
        ["P4W", M[:d4]],
        ["H2B", M[:f6]],
        ["P3W", M[:c4]],
        ["P5B", M[:e5]],
        ["P4W", M[:e5]],
        ["H2B", M[:g4]],
        ["H2W", M[:f3]],
        ["H1B", M[:c6]],
        ["B1W", M[:f4]],
        ["B2B", M[:b4]],
        ["H1W", M[:d2]],
        ["Q1B", M[:e7]],
        ["P1W", M[:a3]],
        ["H2B", M[:e5]],
        ["P1W", M[:b4]],
        ["H2B", M[:d3]],
        EXIT
      ]
      play_index = 0
      allow(Game).to receive(:get_move_human).and_wrap_original do |original, *args|
        if plays[play_index].length == 2 then
          piece_id, move = plays[play_index]
          piece = nil
          args[0][:board].board.find { |r| r.find { |p| piece = p if !p.nil? && p.id == piece_id } }
          play_index += 1
          to_return = [piece, move]
        else
          to_return = "e"
        end
        next to_return
      end
      game_state = game.instance_variable_get(:@game_state)
      settings_state = game.instance_variable_get(:@settings_state)
      settings_state[:render] = false
      result = Game.play_game(game_state, settings_state)
      expected = "end"
      expect(result).to eq(expected)
    end
  end

  context "when playing Veselin vs. Kapsarov (1999)" do
    it "doesn't fail" do
      game = Game.new("fe")
      plays = [
        [M[:e2], M[:e4]],
        [M[:d7], M[:d6]],
        [M[:d2], M[:d4]],
        [M[:g8], M[:f6]],
        [M[:b1], M[:c3]],
        [M[:g7], M[:g6]],
        [M[:c1], M[:e3]],
        [M[:f8], M[:g7]],
        [M[:d1], M[:d2]],
        [M[:c7], M[:c6]],
        [M[:f2], M[:f3]],
        [M[:b7], M[:b5]],
        [M[:g1], M[:e2]],
        [M[:b8], M[:d7]],
        [M[:e3], M[:h6]],
        [M[:g7], M[:h6]],
        [M[:d2], M[:h6]],
        [M[:c8], M[:b7]],
        [M[:a2], M[:a3]],
        [M[:e7], M[:e5]],
        [M[:e1], M[:c1]],
        [M[:d8], M[:e7]],
        [M[:c1], M[:b1]],
        [M[:a7], M[:a6]],
        [M[:e2], M[:c1]],
        [M[:e8], M[:c8]],
        [M[:c1], M[:b3]],
        [M[:e5], M[:d4]],
        [M[:d1], M[:d4]],
        [M[:c6], M[:c5]],
        [M[:d4], M[:d1]],
        [M[:d7], M[:b6]],
        [M[:g2], M[:g3]],
        [M[:c8], M[:b8]],
        [M[:b3], M[:a5]],
        [M[:b7], M[:a8]],
        [M[:f1], M[:h3]],
        [M[:d6], M[:d5]],
        [M[:h6], M[:f4]],
        [M[:b8], M[:a7]],
        [M[:h1], M[:e1]],
        [M[:d5], M[:d4]],
        [M[:c3], M[:d5]],
        [M[:b6], M[:d5]],
        [M[:e4], M[:d5]],
        [M[:e7], M[:d6]],
        [M[:d1], M[:d4]],
        [M[:c5], M[:d4]],
        [M[:e1], M[:e7]],
        [M[:a7], M[:b6]],
        [M[:f4], M[:d4]],
        [M[:b6], M[:a5]],
        [M[:b2], M[:b4]],
        [M[:a5], M[:a4]],
        [M[:d4], M[:c3]],
        [M[:d6], M[:d5]],
        [M[:e7], M[:a7]],
        [M[:a8], M[:b7]],
        [M[:a7], M[:b7]],
        [M[:d5], M[:c4]],
        [M[:c3], M[:f6]],
        [M[:a4], M[:a3]],
        [M[:f6], M[:a6]],
        [M[:a3], M[:b4]],
        [M[:c2], M[:c3]],
        [M[:b4], M[:c3]],
        [M[:a6], M[:a1]],
        [M[:c3], M[:d2]],
        [M[:a1], M[:b2]],
        [M[:d2], M[:d1]],
        [M[:h3], M[:f1]],
        [M[:d8], M[:d2]],
        [M[:b7], M[:d7]],
        [M[:d2], M[:d7]],
        [M[:f1], M[:c4]],
        [M[:b5], M[:c4]],
        [M[:b2], M[:h8]],
        [M[:d7], M[:d3]],
        [M[:h8], M[:a8]],
        [M[:c4], M[:c3]],
        [M[:a8], M[:a4]],
        [M[:d1], M[:e1]],
        [M[:f3], M[:f4]],
        [M[:f7], M[:f5]],
        [M[:b1], M[:c1]],
        [M[:d3], M[:d2]],
        [M[:a4], M[:a7]],
        EXIT
      ]
      play_index = 0
      allow(Game).to receive(:get_move_human).and_wrap_original do |original, *args|
        if plays[play_index].length == 2 then
          piece_location, move = plays[play_index]
          board = args[0][:board]
          piece = board.board[piece_location[0]][piece_location[1]]
          play_index += 1
          to_return = [piece, move]
        else
          to_return = "e"
        end
        next to_return
      end
      game_state = game.instance_variable_get(:@game_state)
      settings_state = game.instance_variable_get(:@settings_state)
      settings_state[:render] = false
      result = Game.play_game(game_state, settings_state)
      expected = "e"
      expect(result).to eq(expected)
    end
  end

  context "When two random computers compete" do
    it "the game end" do
      game_state = {}
      settings_state = {player1: "Random", player2: "Random", cheats: false}
      result = Game.play_game(game_state, settings_state)
      expected = "end"
      expect(result).to eq(expected)
    end
  end
end
