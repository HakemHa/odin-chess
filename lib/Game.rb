require 'json'
require 'set'
require 'time'
Dir[File.join(__dir__, '/pieces', "*")].each { |file| require file }
require_relative "./Grid"
require_relative "./Player"
require_relative "./Computer"
require_relative "./Render"

$debug_file = File.new(File.join(File.dirname(__FILE__), '..', 'spec/dev/null.txt'), 'w')

class Game
  EXIT_CODES = Player.exit_codes + ["save"]
  PLAYERS = [
    "Human",
    "Random",
    "Easy", 
    "Medium",
    "Hard"
  ]
  
  
  def initialize(page = "start")
    @game_state = {}
    @settings_state = {player1: PLAYERS[0], player2: PLAYERS[0], cheats: false, render: true}
    came_from = nil
    Render.open
    while page != "fe" do
      $debug_file.puts("Page #{page}")
      case page
      when "start"
        came_from = "start"
        page = Game.start_game
        next
      when "New Game"
        came_from = "New Game"
        page = Game.play_game(@game_state, @settings_state)
        next
      when "save"
        came_from = "save"
        page = Game.save_game(@game_state, @settings_state)
      when "Continue Game"
        came_from = "Continue Game"
        page = Game.load_game(@game_state, @settings_state)
      when "tutorial"
        came_from = "tutorial"
        page = Game.tutorial_game
        next
      when "settings"
        came_from = "settings"
        page = Game.settings_game(@game_state, @settings_state)
        next
      when "e" || "q"
        page = Game.exit_game(@game_state, @settings_state, came_from)
        next
      when "end"
        came_from = "end"
        page = Game.end_game(@game_state, @settings_state)
        next
      else
        page = "fe"
      end
    end
    Render.close
  end

  def self.get_settings_game_input(selected, options, settings_state)
    act = method(:settings_act)
    exit_codes = [".", "<"]
    input = nil
    while !exit_codes.include?(input)
      Render.settings_game(selected, options, settings_state)
      input = Player.handle_input(act)
      return input if exit_game?(input)
      if !exit_codes.include?(input) then
        selected = (selected+input+options.length)%options.length
      end
    end
    return input, selected
  end

  def self.settings_game(game_state, settings_state)
    options = ["player1", "player2", "cheats", "quit"]
    page = "self"
    selected = 0
    while page != "quit" do
      input, selected = get_settings_game_input(selected, options, settings_state)
      return input if exit_game?(input)
      if input == "<" || options[selected] == "quit" then
        break
      elsif options[selected] == "cheats" then
        settings_state[:cheats] = !settings_state[:cheats]
      elsif options[selected][0...6] == "player" then
        player_settings(settings_state, options[selected])
      end
    end
    return "start"
  end

  def self.settings_act(input)
    case input
    when "up"
      -1
    when "down"
      +1
    when "submit"
      "."
    when "reset"
      "<"
    else
      return nil
    end
  end

  def self.player_settings(settings_state, player)
    selected = PLAYERS.find_index(settings_state[player.to_sym])
    act = method(:player_settings_act)
    exit_codes = [".", "<"]
    input = nil
    while !exit_codes.include?(input)
      player_color = player[player.length-1]
      Render.player_settings(PLAYERS, selected, player_color)
      input = Player.handle_input(act)
      return input if exit_game?(input)
      if !exit_codes.include?(input) then
        selected = (selected+input+PLAYERS.length)%PLAYERS.length
      end
    end
    settings_state[player.to_sym] = PLAYERS[selected]
  end

  def self.player_settings_act(input)
    case input
    when "left"
      -1
    when "right"
      +1
    when "submit"
      "."
    when "reset"
      "<"
    else
      return nil
    end
  end


  def self.tutorial_game
    Render.tutorial
    return "start"
  end

  def self.play_game(game_state, settings_state)
    if game_state.empty? then
      create_game_state(game_state)
    end
    while !game_over?(game_state) do
      move = make_play(game_state, settings_state)
      return move if exit_game?(move)
      game_state[:story].push(move)
      game_state[:turn] = (game_state[:turn]+1)%2
    end
    return "end"
  end

  def self.create_game_state(game_state)
    turn = 0
    board = Grid.new
    populate_board(board)
    story = []
    game_state[:turn] = turn
    game_state[:board] = board
    game_state[:story] = story
    return game_state
  end

  def self.populate_board(board)
    order = ["R1", "H1", "B1", "Q1", "K1", "B2", "H2", "R2"]
    for i in 0...8 do
      pawn_id = "P" + (i+1).to_s + "W"
      pawn = str_to_piece(pawn_id)
      piece_id = order[i] + "W"
      piece = str_to_piece(piece_id)
      board.place(6, i, pawn)
      board.place(7, i, piece)
      pawn_id = "P" + (i+1).to_s + "B"
      pawn = str_to_piece(pawn_id)
      piece_id = order[i] + "B"
      piece = str_to_piece(piece_id)
      board.place(1, i, pawn)
      board.place(0, i, piece)
    end
  end

  def self.str_to_piece(str)
    case str[0]
    when "P"
      return Pawn.new(str)
    when "R"
      return Rook.new(str)
    when "H"
      return Knight.new(str)
    when "B"
      return Bishop.new(str)
    when "Q"
      return Queen.new(str)
    when "K"
      return King.new(str)
    end
  end

  def self.make_play(game_state, settings_state)
    player_mode = game_state[:turn] == 0 ? settings_state[:player1] : settings_state[:player2]
    case player_mode
    when "Human"
      piece, piece_move = get_move_human(game_state, settings_state)
      return piece if exit_game?(piece)
    else
      piece, piece_move = get_move_computer(player_mode, game_state)
      return piece if exit_game?(piece)
    end
    previous_location = game_state[:board].get_location(piece.id)
    removed_piece = execute_move(piece, piece_move, game_state)
    if settings_state[:render] then
      Render.board(game_state, {}, piece, 0, nil, 0)
      sleep(0.2)
    end
    moment = [previous_location, piece_move, removed_piece]
    return moment
  end

  def self.get_move_computer(mode, game_state)
    return Computer.play(mode, game_state)
  end

  def self.get_move_human(game_state, settings_state)
    piece_index = 0
    piece_move_index = 0
    piece = nil
    piece_move = nil
    if settings_state[:cheats] then
      go_back = 0
    end
    while piece_move.nil? do
      valid_moves = get_valid_moves(game_state)
      if settings_state[:render] then
        Render.board(game_state, valid_moves, piece, piece_index, piece_move, piece_move_index)
      end
      input = Player.play
      return input if exit_game?(input)
      piece, piece_index, piece_move, piece_move_index = get_move_state(input, valid_moves, piece, piece_index, piece_move, piece_move_index)
      if settings_state[:cheats] then
        last_piece_moved, go_back = get_cheats_state(game_state, input, go_back, piece_move)
        if !last_piece_moved.nil? then
          piece_move_index = 0
          piece = nil
          piece_move = nil
          valid_moves = get_valid_moves(game_state)
          piece_index = valid_moves.keys.find_index(last_piece_moved) || 0
        end
      end
    end
    move = [piece, piece_move]
    return move
  end

  def self.get_cheats_state(game_state, input, go_back, piece_move)
    story = game_state[:story]
    last_moved_piece = nil
    case input
    when "prev"
      last_moved_piece = revert_game(game_state, go_back)
      go_back = [go_back+1, story.length].min
    when "next"
      last_moved_piece = forward_game(game_state, go_back)
      go_back = [go_back-1, 0].max
    when "."
      if !piece_move.nil? then
        game_state[:story] = story[0...(story.length-go_back)]
      end
    end
    return last_moved_piece, go_back
  end

  def self.revert_game(game_state, go_back)
    story = game_state[:story]
    if go_back == story.length then
      return nil
    end
    to_remove = story[story.length-go_back-1]
    move1, move2, removed_piece = to_remove
    piece_moved = game_state[:board][move2[0]][move2[1]]
    game_state[:board][move1[0]][move1[1]] = piece_moved
    game_state[:board][move2[0]][move2[1]] = nil
    if !removed_piece.nil? then
      case removed_piece
      when /^en_passant/
        move = piece_moved.id[2] == "W" ? +1 : -1
        restore_piece(game_state, [move2[0]+move, move2[1]], removed_piece[10...13])
      when /^castle/
        direction = (move2[1]-move1[1])/2
        rook = game_state[:board][move1[0]][move1[1]+direction]
        game_state[:board][move1[0]][move1[1]+direction] = nil
        if direction == 1 then
          game_state[:board][move1[0]][7] = rook
        else
          game_state[:board][move1[0]][0] = rook
        end
      when /^to_queen/
        piece_moved = Pawn.new("P" + (piece_moved.id[1].to_i-1).to_s + piece_moved.id[2])
        game_state[:board][move1[0]][move1[1]] = piece_moved
        restore_piece(game_state, move2, removed_piece[8...11]) if removed_piece.length > 8
      else
        restore_piece(game_state, move2, removed_piece)
      end
    end
    game_state[:turn] = (game_state[:turn]+1)%2
    return piece_moved
  end

  def self.restore_piece(game_state, location, piece_id)
    piece = str_to_piece(piece_id)
    game_state[:board][location[0]][location[1]] = piece
  end

  def self.forward_game(game_state, go_back)
    story = game_state[:story]
    if go_back == 0 then
      return nil
    end
    to_add = story[story.length-go_back]
    move1, move2, _ = to_add
    piece_moved = game_state[:board][move1[0]][move1[1]]
    execute_move(piece_moved, move2, game_state)
    game_state[:turn] = (game_state[:turn]+1)%2
    return nil
  end

  def self.get_move_state(input, valid_moves, piece, piece_index, piece_move, piece_move_index)
    case input
    when "up"
      piece, piece_index, piece_move, piece_move_index = move_state_up(valid_moves, piece, piece_index, piece_move, piece_move_index)
    when "down"
      piece, piece_index, piece_move, piece_move_index = move_state_down(valid_moves, piece, piece_index, piece_move, piece_move_index)
    when "right"
      piece, piece_index, piece_move, piece_move_index = move_state_up(valid_moves, piece, piece_index, piece_move, piece_move_index)
    when "left"
      piece, piece_index, piece_move, piece_move_index = move_state_down(valid_moves, piece, piece_index, piece_move, piece_move_index)
    when "."
      if piece.nil? then
        piece = valid_moves.keys[piece_index]
      else
        piece_move = valid_moves[piece][piece_move_index]
      end
    when "<"
      if !piece.nil? then
        piece_move_index = 0
        piece = nil
      end
    end
    return piece, piece_index, piece_move, piece_move_index
  end

  def self.move_state_up(valid_moves, piece, piece_index, piece_move, piece_move_index)
    if piece.nil? then
      piece_index = (piece_index+1)%valid_moves.keys.length
    else
      piece_move_index = (piece_move_index+1)%valid_moves[piece].length
    end
    return piece, piece_index, piece_move, piece_move_index
  end

  def self.move_state_down(valid_moves, piece, piece_index, piece_move, piece_move_index)
    if piece.nil? then
      limit = valid_moves.keys.length
      piece_index = (piece_index-1+limit)%limit
    else
      limit = valid_moves[piece].length
      piece_move_index = (piece_move_index-1+limit)%limit
    end
    return piece, piece_index, piece_move, piece_move_index
  end

  def self.execute_move(piece, move, game_state)
    board = game_state[:board]
    piece_location = board.get_location(piece.id)
    en_passant = false
    if piece.id[0] == "P" then
      if board.board[move[0]][move[1]].nil? && piece_location[1] != move[1] then
        en_passant = true
      end
    end
    castle = piece.id[0] == "K" && (piece_location[1]-move[1]).abs == 2
    turn_to_queen = piece.id[0] == "P" && [0, 7].include?(move[0])
    if en_passant then
      return do_en_passant(piece, move, game_state)
    elsif castle then
      return do_castle(piece, move, game_state)
    elsif turn_to_queen then
      return do_turn_to_queen(piece, move, game_state)
    else
      return do_move(piece, move, game_state)
    end
  end

  def self.do_en_passant(piece, move, game_state)
    board = game_state[:board]
    piece_location = board.get_location(piece.id)
    color = piece.id[2]
    board.remove(piece_location[0], piece_location[1])
    board.place(move[0], move[1], piece)
    if color == "W" then
      removed_piece = board.board[move[0]+1][move[1]]
      board.remove(move[0]+1, move[1])
    else
      removed_piece = board.board[move[0]-1][move[1]]
      board.remove(move[0]-1, move[1])
    end
    return "en_passant#{removed_piece.id}"
  end

  def self.do_castle(piece, move, game_state)
    board = game_state[:board]
    piece_location = board.get_location(piece.id)
    board.remove(piece_location[0], piece_location[1])
    board.place(move[0], move[1], piece)
    if piece_location[1] > move[1] then
      rook = board.board[move[0]][0]
      board.remove(move[0], 0)
      board.place(move[0], move[1]+1, rook)
    else
      rook = board.board[move[0]][7]
      board.remove(move[0], 7)
      board.place(move[0], move[1]-1, rook)
    end
    return "castle"
  end

  def self.do_turn_to_queen(piece, move, game_state)
    board = game_state[:board]
    color = piece.id[2]
    piece_location = board.get_location(piece.id)
    removed_piece = board.board[move[0]][move[1]]
    board.remove(piece_location[0], piece_location[1])
    new_queen = Queen.new("Q#{piece.id[1].to_i+1}#{color}")
    board.place(move[0], move[1], new_queen)
    return "to_queen#{removed_piece.nil? ? nil : removed_piece.id}"
  end

  def self.do_move(piece, move, game_state)
    board = game_state[:board]
    piece_location = board.get_location(piece.id)
    removed_piece = board.board[move[0]][move[1]]
    board.remove(piece_location[0], piece_location[1])
    board.place(move[0], move[1], piece)
    return removed_piece.nil? ? nil : removed_piece.id
  end

  def self.get_valid_moves(game_state)
    turn = game_state[:turn]
    board = game_state[:board]
    color = turn == 0 ? "W" : "B"
    pieces = get_valid_pieces(board, color)
    in_check = in_check?(game_state)
    valid_moves = {}
    for piece in pieces do
      if piece.id[0] == "K" || in_check then
        moves = piece.moves(game_state)
        for move in moves do
          if is_valid_move?([piece, move], game_state) then
            if !valid_moves.keys.include?(piece) then
              valid_moves[piece] = []
            end
            valid_moves[piece].push(move)
          end
        end
      else
        moves = piece.moves(game_state)
        if moves.length > 0 then
          valid_moves[piece] = piece.moves(game_state)
        end
      end
    end
    return valid_moves
  end

  def self.is_valid_move?(move, game_state)
    copy_game_state = Game.copy_game(game_state)
    execute_move(*move, copy_game_state)
    return !in_check?(copy_game_state)
  end

  def self.in_check?(game_state)
    board = game_state[:board]
    turn = game_state[:turn]
    color = turn == 0 ? "W" : "B"
    enemy_color = color == "W" ? "B" : "W"
    enemy_pieces = get_valid_pieces(board, enemy_color)
    king_location = board.get_location("K1#{color}")
    for piece in enemy_pieces do
      if piece.moves(game_state).include?(king_location) then
        return true
      end
    end
    return false
  end

  def self.get_valid_pieces(board, color)
    valid_pieces = []
    for row in board.board do
      for piece in row do
        if !piece.nil? && piece.id[2] == color then
          valid_pieces.push(piece)
        end
      end
    end
    return valid_pieces
  end

  def self.exit_game?(input)
    EXIT_CODES.include?(input)
  end

  def self.end_game(game_state, settings_state)
    Render.end_game(winner(game_state))
    STDIN.getch
    return "exit"
  end

  def self.winner(game_state)
    if checkmate?(game_state) then
      if game_state[:turn] == 0 then
        return "B"
      else
        return "W"
      end
    else
      if stalemate?(game_state) then
        return "stalemate"
      elsif threefold?(game_state) then
        return "threefold"
      elsif move50?(game_state) then
        return "50 moves"
      end
    end
    return "mutual agreement"
  end

  def self.game_over?(game_state)
    # mutual
    checkmate?(game_state) || stalemate?(game_state) || threefold?(game_state) || move50?(game_state)
  end

  def self.checkmate?(game_state)
    no_more_moves = get_valid_moves(game_state) == {}
    in_check = in_check?(game_state)
    return no_more_moves && in_check
  end

  def self.stalemate?(game_state)
    no_more_moves = get_valid_moves(game_state) == {}
    checkmate = checkmate?(game_state)
    return no_more_moves && !checkmate
  end

  def self.threefold?(game_state)
    story = game_state[:story]
    if story.length < 6 then
      return false
    end
    last_move1 = story[story.length-1]
    last_move2 = story[story.length-2]
    previous_last_move1 = story[story.length-5]
    previous_last_move2 = story[story.length-6]
    return last_move1 == previous_last_move1 && last_move2 == previous_last_move2
  end

  def self.move50?(game_state)
    story = game_state[:story]
    if story.length < 50 then
      return false
    end
    return story[story.length-50...story.length].all? { |move| move[2].nil? }
  end

  def self.exit_game(game_state, settings_state, page = "start")
    return "hard_exit" if game_state == {}
    options = ["yes", "no"]
    selected = 0
    act = method(:exit_act)
    choice = nil
    while choice.nil?
      Render.exit_game(options, selected)
      input = Player.handle_input(act)
      return "hard_exit" if exit_game?(input)
      if input.instance_of?(Integer) then
        selected = (selected+input+options.length)%options.length
      elsif input == "." then
        choice = options[selected]
      else
        choice = input
      end
    end
    return page if choice == "no"
    return "hard_exit"
  end

  def self.exit_act(input)
    case input
    when "left"
      -1
    when "right"
      +1
    when "submit"
      "."
    when "reset"
      "no"
    when "n"
      "no"
    when "y"
      "yes"
    else
      return nil
    end
  end

  def self.start_game
    options = ["New Game", "Continue Game", "tutorial", "settings", "exit"]
    selected = 0
    act = method(:start_act)
    exit_code = "."
    input = nil
    while input != exit_code
      Render.start_game(options, selected)
      input = Player.handle_input(act)
      return input if exit_game?(input)
      selected = (selected+input+options.length)%options.length if input != exit_code
    end
    return options[selected]
  end

  def self.start_act(input)
    case input
    when "up"
      -1
    when "down"
      +1
    when "submit"
      "."
    else
      return nil
    end
  end

  def self.save_game(game_state, settings_state)
    title = Time.now.to_s
    Render.save_game(game_state, settings_state, title)
    first_title = title
    act = method(:save_act)
    input = nil
    input = Player.handle_input(act)
    while input != "." do
      if input == "fe" then
        return input
      end
      if input == "<" && title.length == 0 then
        return "New Game"
      end
      case input
      when "<"
        if title == first_title then
          title = ""
        else
          title = title[0...title.length-1]
        end
      else
        if title == first_title then
          title = input
        else
          title += input
        end
      end
      Render.save_game(game_state, settings_state, title)
      input = Player.handle_input(act)
    end
    copy_game_state = copy_game(game_state)
    copy_game_state[:board] = copy_game_state[:board].board.map { |row| row.map { |piece| piece.nil? ? piece : piece.id } }
    state = [copy_game_state, settings_state]
    saved_state = JSON.generate(state)
    save_file = File.new(File.join(File.dirname(__FILE__), 'saves', title + ".txt"), 'w')
    save_file.print(saved_state)
    return "New Game"
  end

  def self.save_act(input)
    case input
    when "submit"
      return "."
    when "reset"
      return "<"
    else
      if input.nil? then
        return nil
      end
      if input.length == 1
        return input
      end
    end
    nil
  end

  def self.load_game(game_state, settings_state)
    save = select_save_file
    return save if exit_game?(save)
    loaded_game_state, loaded_settings_state = save
    for key in loaded_game_state.keys do
      game_state[key] = loaded_game_state[key]
    end
    for key in loaded_settings_state.keys do
      settings_state[key] = loaded_settings_state[key]
    end
    return "New Game"
  end

  def self.select_save_file
    saves_dir = Dir.entries(File.join(File.dirname(__FILE__), "saves"))
    saves_dir.delete(".")
    saves_dir.delete("..")
    selected = 0
    act = method(:start_act)
    exit_code = "."
    input = nil
    while input != exit_code
      Render.load_game(saves_dir, selected, parse_save_file(saves_dir[selected])[0])
      input = Player.handle_input(act)
      return input if exit_game?(input)
      selected = (selected+input+saves_dir.length)%saves_dir.length if input != exit_code
    end
    filename = saves_dir[selected]
    return parse_save_file(filename)
  end

  def self.parse_save_file(filename)
    file = File.open(File.join(File.dirname(__FILE__), "saves", filename), "r")
    file = file.read
    save = JSON.parse(file)
    save[0].transform_keys!(&:to_sym)
    save[1].transform_keys!(&:to_sym)
    id_board = save[0][:board]
    load_board = Grid.new
    load_board.board = Array.new(8) { Array.new(8) }
    for y in 0...8 do
      for x in 0...8 do
        piece_id = id_board[y][x]
        if !piece_id.nil? then
          load_board.board[y][x] = str_to_piece(piece_id)
        else
          nil
        end
      end
    end
    save[0][:board] = load_board
    return save
  end

  def self.copy_game(game_state)
    board = game_state[:board]
    turn = game_state[:turn]
    story = game_state[:story]
    copy_board = Grid.new
    copy_board.board = Array.new(8) { Array.new(8) }
    for y in 0...8 do
      for x in 0...8 do
        piece = board.board[y][x]
        if !piece.nil? then
          copy_board.board[y][x] = str_to_piece(piece.id)
        else
          nil
        end
      end
    end
    copy_story = JSON.parse(JSON.generate(story))
    copy_game_state = {board: copy_board, turn: turn, story: copy_story}
    return copy_game_state
  end

  def self.pretty_print(game_state)
    turn = game_state[:turn]
    board = game_state[:board]
    $stdout.print("Turn: ", turn, "\n")
    for row in board.board do
      pretty_row = row.map { |piece| piece.nil? ? "   " : piece.id }
      pretty_row = pretty_row.join(" | ")
      long_line = "_"*45
      $stdout.print(pretty_row, "\n", long_line, "\n")
    end
  end
end
