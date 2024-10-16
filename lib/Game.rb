require 'json'
require 'set'
Dir[File.join(__dir__, '/pieces', "*")].each { |file| require file }
require_relative "./Grid"
require_relative "./Player"
require_relative "./Render"

class Game
  EXIT_CODES = ["e", "fe"]
  PLAYERS = [
    "Human",
    "Random",
    "Easy", 
    "Medium",
    "Hard"
  ]


  def initialize(page = "start")
    @game_state = nil
    @settings_state = {player1: PLAYERS[0], player2: PLAYERS[0], cheats: false}
    came_from = nil
    Render.open
    while page != "fe" do
      case page
      when "start"
        came_from = "start"
        page = start_game
        next
      when "play"
        came_from = "play"
        page = play_game(@game_state, @settings_state)
        next
      when "tutorial"
        came_from = "tutorial"
        page = tutorial_game
        next
      when "settings"
         came_from = "settings"
        page = settings_game(@game_state, @settings_state)
        next
      when "e"
        page = exit_game(@game_state, @settings_state, came_from)
        next
      when "end"
        came_from = "end"
        page = end_game(@game_state, @settings_state)
        next
      else
        page = "fe"
      end
    end
    Render.close
  end

  def settings_game(game_state, settings_state)
    options = ["player1", "player2", "cheats", "quit"]
    page = "self"
    selected = 0
    while page != "quit" do
      act = method(:settings_act)
      exit_codes = [".", "<"]
      input = nil
      while !exit_codes.include?(input)
        Render.settings_game(options, selected, settings_state)
        input = Player.handle_input(nil, act, selected, options)
        return input if exit_game?(input)
        if !exit_codes.include?(input) then
          selected = input || 0
        end
      end
      if input == "." then
        case options[selected]
        when "player1"
          result = player_settings(settings_state, :player1)
          return result if exit_game?(result)
          next
        when "player2"
          result = player_settings(settings_state, :player2)
          return result if exit_game?(result)
          next
        when "cheats"
          settings_state[:cheats] = !settings_state[:cheats]
          next
        when "quit"
          page = "quit"
          next
        end
      elsif input == "<"
        page = "quit"
      end
    end
    return "start"
  end

  def player_settings(settings_state, player)
    options = PLAYERS
    selected = options.find_index(settings_state[player])
    act = method(:settings_act)
    exit_codes = [".", "<"]
    input = nil
    while !exit_codes.include?(input)
      last = player.to_s[player.to_s.length-1]
      Render.player_settings(options, selected, last)
      input = Player.handle_input(nil, act, selected, options)
      return input if exit_game?(input)
      if !exit_codes.include?(input) then
        selected = input || 0
      end
    end
    settings_state[player] = options[selected]
  end

  def settings_act(input, state)
    selected, options_length = state[0], state[1].length
    case input
    when "+1"
      selected = (selected+1)%options_length
    when "-1"
      selected = (selected-1+options_length)%options_length
    when "submit"
      "."
    when "reset"
      "<"
    when "exit"
      return "e"
    when "hard_exit"
      return "fe"
    else
      return nil
    end
  end

  def tutorial_game
    Render.tutorial
    return "start"
  end

  def play_game(game_state, settings_state)
    if game_state.nil? then
      game_state = create_game_state
      @game_state = game_state
    end
    while !game_over?(game_state) do
      move = make_play(game_state, settings_state)
      return move if exit_game?(move)
      game_state[:story].push(move)
      game_state[:turn] = (game_state[:turn]+1)%2
    end
    return "end"
  end

  def create_game_state
    turn = 0
    board = Grid.new
    populate_board(board)
    story = []
    return {turn: turn, board: board, story: story}
  end

  def populate_board(board)
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

  def str_to_piece(str)
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

  def make_play(game_state, settings_state)
    board = game_state[:board]
    valid_moves = get_valid_moves(game_state)
    piece_index = 0
    previous_location = nil
    piece_move = nil
    move = nil
    while move.nil? do
      board.selected = nil
      pieces = valid_moves.keys
      piece = select_from(pieces, piece_index, game_state)
      return piece if exit_game?(piece)
      previous_location = board.get_location(piece.id)
      board.selected = previous_location 
      piece_index = pieces.find_index(piece)
      piece_moves = valid_moves[piece]
      piece_move = select_from(piece_moves, 0, game_state)
      return piece_move if exit_game?(piece_move)
      next if piece_move == "<"
      move = [piece, piece_move]
    end
    board.selected = nil
    removed_piece = execute_move(*move, game_state)
    moment = [previous_location, piece_move, removed_piece]
    return moment
  end

  def select_from(list, index, game_state)
    input = nil
    exit_code = "."
    while input != exit_code
      Render.select_from(list, index, game_state)
      input = Player.play(index, list.length)
      return input if exit_game?(input)
      if input == "<" && list[index].instance_of?(Array) then
        return input
      end
      index = input if input != exit_code
    end
    return list[index]
  end

  def execute_move(piece, move, game_state)
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

  def do_en_passant(piece, move, game_state)
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
    return "en_passant#{removed_piece.nil? ? nil : removed_piece.id}"
  end

  def do_castle(piece, move, game_state)
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

  def do_turn_to_queen(piece, move, game_state)
    board = game_state[:board]
    color = piece.id[2]
    piece_location = board.get_location(piece.id)
    removed_piece = board.board[move[0]][move[1]]
    board.remove(piece_location[0], piece_location[1])
    new_queen = Queen.new("Q#{piece.id[1].to_i+1}#{color}")
    board.place(move[0], move[1], new_queen)
    return "to_queen#{removed_piece.nil? ? nil : removed_piece.id}"
  end

  def do_move(piece, move, game_state)
    board = game_state[:board]
    piece_location = board.get_location(piece.id)
    removed_piece = board.board[move[0]][move[1]]
    board.remove(piece_location[0], piece_location[1])
    board.place(move[0], move[1], piece)
    return removed_piece.nil? ? nil : removed_piece.id
  end

  def get_valid_moves(game_state)
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

  def is_valid_move?(move, game_state)
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
    execute_move(*move, copy_game_state)
    return !in_check?(copy_game_state)
  end

  def in_check?(game_state)
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

  def get_valid_pieces(board, color)
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

  def exit_game?(input)
    EXIT_CODES.include?(input)
  end

  def end_game(game_state, settings_state)
    Render.end_game(winner(game_state))
    STDIN.getch
    return "exit"
  end

  def winner(game_state)
    if get_valid_moves(game_state) == {} then
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

  def game_over?(game_state)
    # mutual
    get_valid_moves(game_state) == {} || stalemate?(game_state) || threefold?(game_state) || move50?(game_state)
  end

  def stalemate?(game_state)
    return false
  end

  def threefold?(game_state)
    return false
  end

  def move50?(game_state)
    return false
  end

  def exit_game(game_state, settings_state, page = "start")
    return "hard_exit" if game_state.nil?
    options = ["yes", "no"]
    selected = 0
    act = method(:exit_act)
    exit_codes = [".", "e", "fe"]
    input = nil
    while !exit_codes.include?(input)
      Render.exit_game(options, selected)
      input = Player.handle_input(nil, act, selected, options)
      return input if exit_game?(input)
      if !exit_codes.include?(input) then
        selected = input || 0
      end
    end
    return page if options[selected] == "no"
    return "hard_exit"
  end

  def exit_act(input, state)
    selected, options_length = state[0], state[1].length
    case input
    when "+1"
      selected = (selected+1)%options_length
    when "-1"
      selected = (selected-1+options_length)%options_length
    when "submit"
      "."
    when "reset"
      nil
    when "exit"
      nil
    when "hard_exit"
      return "fe"
    else
      return nil
    end
  end

  def start_game
    options = ["play", "tutorial", "settings", "exit"]
    selected = 0
    act = method(:start_act)
    exit_code = "."
    input = nil
    while input != exit_code
      Render.start_game(options, selected)
      input = Player.handle_input(nil, act, selected, options)
      return input if exit_game?(input)
      selected = input if input != exit_code
    end
    if input == "." then
      return options[selected]
    else
      return input
    end
  end

  def start_act(input, state)
    selected, options_length = state[0], state[1].length
    case input
    when "+1"
      selected = (selected+1)%options_length
    when "-1"
      selected = (selected-1+options_length)%options_length
    when "submit"
      "."
    when "reset"
      nil
    when "exit"
      return "e"
    when "hard_exit"
      return "fe"
    else
      return nil
    end
  end

  def pretty_print(game_state)
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
