Dir[File.join(__dir__, '/pieces', "*")].each { |file| require file }
require_relative "./Grid"

class Render

  WIDTH = 13*8
  HEIGHT = 5*8
  PIECES = {
    king: <<-KING,
  ███ █ ███  
 █   █ █   █ 
 █   █ █   █ 
  █  █ █  █  
   ███████   
    KING
    queen: <<-QUEEN,
 ██   █   ██ 
████ █ █ ████
█████ █ █████
 █████ █████ 
  █████████  
    QUEEN
    rook: <<-ROOK,
 ███ ███ ███ 
 ███ ███ ███ 
  ██ ███ ██  
   ███████   
   ███████   
    ROOK
    knight: <<-KNIGHT,
        ██   
   █████ ██  
  ██████  ██ 
 ██ █████████
 ████████████
    KNIGHT
    bishop: <<-BISHOP,
    ████     
     ████    
      ████   
  ██   ████  
  █████████  
    BISHOP
    pawn: <<-PAWN,
    █████    
   ███████   
   ███████   
  █ █████ █  
 ███████████ 
    PAWN
    move: <<-MOVE,
█████████████
██         ██
██         ██
██         ██
█████████████
    MOVE
    empty: <<-EMPTY,
             
             
             
             
             
    EMPTY
  }

  Mini_HEIGHT = 8
  Mini_WIDTH = 16
  Mini_PIECES = {
    king: '♚ ',
    queen: '♛ ',
    rook: '♜ ',
    knight: '♞ ',
    bishop: '♝ ',
    pawn: '♟ ',
    move: '██',
    empty: "  ",
  }
  def self.start_game(options, selected)
    system("clear")
    space = " "*10
    title = "♔  CHESS ♚"
    banner = space+title+space
    $stdout.print(banner, "\n\n")
    for i in 0...options.length do
      option = options[i]
      if i == selected then
        align = get_align(option.length+2, (banner).length, "center")
        $stdout.print(" "*align, "♙ ", "\e[30;47m", option.capitalize, "\e[0m", "\n\n")
      else
        align = get_align(option.length, (banner).length, "center")
        $stdout.print(" "*align+option.capitalize, "\n\n")
      end
    end
  end

  def self.settings_game(selected, options, settings_state)
    system("clear")
    space = " "*10
    title = "Settings"
    banner = space+title+space
    $stdout.print(banner, "\n\n")
    piece = "♖"
    for i in 0...options.length do
      option = options[i].capitalize
      if i == selected then
        $stdout.print(" ", "#{piece} ", "\e[30;47m")
      else
        $stdout.print(" "*3)
      end
      case option
      when /^Player/
        render_player_options(option, settings_state)
      when "Cheats"
        state = settings_state[option.downcase.to_sym]
        $stdout.print(option, "\e[0m", ": #{state ? "On" : "Off"}", "\n\n", "\e[0m")
      when "Quit"
        $stdout.print(option, "\n\n", "\e[0m")
      end
    end
  end

  def self.render_player_options(option, settings_state)
    state = settings_state[option.downcase.to_sym]
    $stdout.print(option, "\e[0m", ": ")
    bold = "\e[1;4m"
    colors = ["\e[37m", "\e[34m", "\e[32m", "\e[33m", "\e[31m"]
    types = ["Human", "Random", "Easy", "Medium", "Hard"]
    for i in 0...types.length do
      color = colors[i]
      type = types[i]
      if state == type then
        $stdout.print(bold)
      end
      $stdout.print(color, type)
      $stdout.print("\e[0m")
      if i == types.length-1 then
        $stdout.print(";")
      else
        $stdout.print(", ")
      end
    end
    $stdout.print("\n\n")
  end

  def self.player_settings(options, selected, num)
    line = num == "1" ? 3 : 5
    reset_colors = ["\e[37m", "\e[34m", "\e[32m", "\e[33m", "\e[31m"]
    background_colors = ["\e[47m", "\e[44m", "\e[42m", "\e[43m", "\e[41m"]
    cols = {}
    start_col = "  PlayerX: ".length+2
    col = start_col
    for option in options do
      cols[option] = col
      col += option.length + 2
    end
    selected_option = options[selected]
    $stdout.print("\e7")
    $stdout.print("\e[#{line};#{start_col}H")
    for i in 0...options.length do
      color = reset_colors[i]
      type = options[i]
      $stdout.print(color, type)
      $stdout.print("\e[0m")
      if i == options.length-1 then
        $stdout.print(";")
      else
        $stdout.print(", ")
      end
    end
    $stdout.print("\e[#{line};#{cols[selected_option]}H")
    $stdout.print(background_colors[selected], selected_option)
    $stdout.print("\e8")
  end

  def self.tutorial
    system("clear")
    tutorial_text = <<-TUTORIAL
                Tutorial

    How to play chess? 
    - To learn how to play chess visit https://www.chess.com/learn-how-to-play-chess#special-rules-chess

    How to use this program?
    - Use arrow keys (←, ↑, →, ↓) to choose a move and press enter or space to confirm choice
    - To exit press e(xit) or q(uit)
    - To save press s(ave)
    - If cheats are on you can go through the story of the game with p(revious) and n(ext)
      - Going back doesn't prevent you from returning to the state you left the game, 
        but if you make a new move all the moves following the point you changed can't
        be accessed anymore
    - To forfeit press f, to ask for a draw press d (only available against a human)
    
    Press any key to exit tutorial.
    TUTORIAL
    $stdout.print(tutorial_text)
    $stdin.getch
  end

  def self.board(game_state, valid_moves, selected_piece, selected_piece_index, selected_move, selected_move_index)
    system("clear")
    for y in 0...8 do
      for x in 0...8 do
        piece_text, piece_color = get_piece_render(y, x, game_state, valid_moves, selected_piece, selected_piece_index, selected_move, selected_move_index)
        background_color = get_background_color(y, x, game_state, valid_moves, selected_piece, selected_piece_index, selected_move, selected_move_index)
        render_block(y, x, piece_text, piece_color, background_color)
      end
      print("\n\n")
    end
  end

  def self.get_background_color(y, x, game_state, valid_moves, selected_piece, selected_piece_index, selected_move, selected_move_index)
    piece_option_color = "\e[48;2;0;180;216m"
    piece_selected_color = "\e[48;2;0;119;182m"
    move_option_color = "\e[48;2;172;216;167m"
    move_selected_color = "\e[48;2;70;146;60m"
    white = "\e[47m"
    black = "\e[40m"
    piece = game_state[:board].board[y][x]
    if piece.nil? then
      return (x+y)%2 == 0 ? white : black
    end
    if selected_piece.nil? then
      if valid_moves.keys[selected_piece_index] == piece then
        return piece_option_color
      end
    else
      if piece == selected_piece then
        return piece_selected_color
      elsif !valid_moves.empty? && valid_moves[selected_piece].include?([y, x]) then
        return valid_moves[selected_piece][selected_move_index] == [y, x] ? move_selected_color : move_option_color
      end
    end
    return (x+y)%2 == 0 ? white : black
  end

  def self.get_piece_render(y, x, game_state, valid_moves, selected_piece, selected_piece_index, selected_move, selected_move_index)
    piece_id = {"P" => :pawn, "R" => :rook, "H" => :knight, "B" => :bishop, "Q" => :queen, "K" => :king}
    white_color = "\e[38;5;250m"
    black_color = "\e[38;5;240m"
    option_color = "\e[38;2;172;216;167m"
    selected_color = "\e[38;2;70;146;60m"
    piece = game_state[:board].board[y][x]
    if !piece.nil? then
        piece_text = PIECES[piece_id[piece.id[0]]]
        piece_color = piece.id[2] == "W" ? white_color : black_color
    else
      if !selected_piece.nil? && !valid_moves.empty? && valid_moves[selected_piece].include?([y, x]) then
        piece_text = PIECES[:move]
        piece_color = option_color
        if valid_moves[selected_piece][selected_move_index] == [y, x] then
          piece_color = selected_color
        end
      else
        piece_text = PIECES[:empty]
        piece_color = "\e[39m"
      end
    end
    return piece_text, piece_color
  end

  def self.render_block(y, x, piece_text, piece_color, background_color)
    buffer = ""
    block_height = HEIGHT/8
    block_width = WIDTH/8
    default_background = "\e[49m"
    default_color = "\e[39m"
    for line in ((y*block_height)+1)...(((y+1)*block_height)+1) do
      buffer += "\e[#{line};#{(x*block_width)+1}H"
      buffer += background_color+piece_color
      origin = (line-((y*block_height)+1))*(block_width+1)
      for i in 0...block_width do
        buffer += piece_text[origin+i]
      end
      buffer += default_background + default_color
    end
    print(buffer)
  end

  def self.mini_board(game_state, valid_moves, selected_piece, selected_piece_index, selected_move, selected_move_index, position = [0, 0])
    buffer = ""
    buffer += "\e[#{position[0]+1};#{position[1]}f"
    for y in 0...8 do
      for x in 0...8 do
        piece_text, piece_color = mini_get_piece_render(y, x, game_state, valid_moves, selected_piece, selected_piece_index, selected_move, selected_move_index)
        background_color = mini_get_background_color(y, x, game_state, valid_moves, selected_piece, selected_piece_index, selected_move, selected_move_index)
        buffer += mini_render_block(piece_text, piece_color, background_color)
      end
      buffer += "\e[#{position[0]+y+2};#{position[1]}f"
    end
    print(buffer)
  end

  def self.mini_get_background_color(y, x, game_state, valid_moves, selected_piece, selected_piece_index, selected_move, selected_move_index)
    piece_option_color = "\e[48;2;0;180;216m"
    piece_selected_color = "\e[48;2;0;119;182m"
    move_option_color = "\e[48;2;172;216;167m"
    move_selected_color = "\e[48;2;70;146;60m"
    white = "\e[47m"
    black = "\e[40m"
    piece = game_state[:board].board[y][x]
    if piece.nil? then
      return (x+y)%2 == 0 ? white : black
    end
    if selected_piece.nil? then
      if valid_moves.keys[selected_piece_index] == piece then
        return piece_option_color
      end
    else
      if piece == selected_piece then
        return piece_selected_color
      elsif !valid_moves.empty? && valid_moves[selected_piece].include?([y, x]) then
        return valid_moves[selected_piece][selected_move_index] == [y, x] ? move_selected_color : move_option_color
      end
    end
    return (x+y)%2 == 0 ? white : black
  end

  def self.mini_get_piece_render(y, x, game_state, valid_moves, selected_piece, selected_piece_index, selected_move, selected_move_index)
    piece_id = {"P" => :pawn, "R" => :rook, "H" => :knight, "B" => :bishop, "Q" => :queen, "K" => :king}
    white_color = "\e[37m"
    black_color = "\e[30m"
    option_color = "\e[38;2;172;216;167m"
    selected_color = "\e[38;2;70;146;60m"
    piece = game_state[:board].board[y][x]
    if !piece.nil? then
        piece_text = Mini_PIECES[piece_id[piece.id[0]]]
        piece_color = piece.id[2] == "W" ? white_color : black_color
    else
      if !selected_piece.nil? && !valid_moves.empty? && valid_moves[selected_piece].include?([y, x]) then
        piece_text = Mini_PIECES[:move]
        piece_color = option_color
        if valid_moves[selected_piece][selected_move_index] == [y, x] then
          piece_color = selected_color
        end
      else
        piece_text = Mini_PIECES[:empty]
        piece_color = "\e[39m"
      end
    end
    return piece_text, piece_color
  end

  def self.mini_render_block(piece_text, piece_color, background_color)
    buffer = ""
    block_height = Mini_HEIGHT/8
    block_width = Mini_WIDTH/8
    default_background = "\e[49m"
    default_color = "\e[39m"
    for line in 1..block_height do
      #buffer += "\e[#{line};#{(x*block_width)+1}H"
      buffer += background_color+piece_color
      origin = (line-1)*(block_width+1)
      for i in 0...block_width do
        buffer += piece_text[origin+i]
      end
      buffer += default_background + default_color
    end
    return buffer
  end

  def self.save_game(game_state, settings_state, title)
    system("clear")
    print("Saving...", "\n\n")
    print("Save as: #{title}", "\n\n\n")
    print("(Press enter or space to confirm and backspace\non an empty filename to cancel)", "\n\n")
    mini_board(game_state, {}, nil, 0, nil, 0, [0, 50])
    print("     Turn: #{game_state[:turn] == 0 ? "W" : "B"}")
  end

  def self.load_game(saves, selected, preview_game_state)
    system("clear")
    print("Choose game to load: \n\n")
    underline_bold = "\e[1;4m"
    reset_style = "\e[22;24m"
    for option in saves do
      if option == saves[selected] then
        print("-> #{underline_bold+option+reset_style}")
      else
        print("   #{option}")
      end
      print("\n\n")
    end
    mini_board(preview_game_state, {}, nil, 0, nil, 0, [1+selected*2, 50])
  end

  def self.end_game(winner)
    system("clear")
    $stdout.print("    Game Over", "\n")
    if ["W", "B"].include?(winner) then
      piece = winner == "W" ? "♔" : "♚"
      $stdout.print("    Player #{piece}  won!", "\n")
    else
      $stdout.print("The game ended in draw by #{winner}!", "\n")
    end
  end

  def self.exit_game(options, selected)
    system("clear")
    option = options[selected]
    case option
    when "yes"
      $stdout.print("Are you sure you want to exit? \e[1;4my\e[0m / n", "\n")
    when "no"
      $stdout.print("Are you sure you want to exit? y / \e[1;4mn\e[0m", "\n")
    end
  end

  def self.get_align(to_align, reference, type)
    case type
    when "center"
      return (reference-to_align)/2
    when "left"
    else
      0
    end
  end

  def self.open
    $stdout.print("\e[?25l")
  end

  def self.close
    $stdout.print("\e[?25h")
    system("clear")
  end

end