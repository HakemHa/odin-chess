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

  def self.start_game(options, selected)
    system("clear")
    space = " "*10
    title = "♔  CHESS ♚"
    banner = space+title+space
    $stdout.print(banner, "\n")
    for i in 0...options.length do
      option = options[i]
      if i == selected then
        align = get_align(option.length+2, (banner).length, "center")
        $stdout.print(" "*align, "♙ ", "\e[30;47m", option, "\e[0m", "\n\n")
      else
        align = get_align(option.length, (banner).length, "center")
        $stdout.print(" "*align+option, "\n\n")
      end
    end
  end

  def self.settings_game(options, selected, settings_state)
    system("clear")
    space = " "*10
    title = "Settings"
    banner = space+title+space
    $stdout.print(banner, "\n")
    piece = "♖"
    for i in 0...options.length do
      option = options[i]
      case option
      when /^player/
        state = settings_state[option.to_sym]
        if i == selected then
          $stdout.print(" ", "#{piece} ", "\e[30;47m")
        else
          $stdout.print(" "*3)
        end
        $stdout.print(option.capitalize, "\e[0m", ": ")
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
      when "cheats"
        state = settings_state[option.to_sym]
        if i == selected then
          $stdout.print(" ", "#{piece} ", "\e[30;47m")
        else
          $stdout.print(" "*3)
        end
        $stdout.print(option, "\e[0m", ": #{state ? "On" : "Off"}", "\n\n")
      else
        if i == selected then
          $stdout.print(" ", "#{piece} ", "\e[30;47m", option, "\e[0m", "\n\n")
        else
          $stdout.print(" "*3+option, "\n\n")
        end
      end
    end
  end

  def self.player_settings(options, selected, num)
    line = num == "1" ? 2 : 4
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
    - Use arrow keys (←, ↑, →, ↓) to choose a move and press enter or space to confirm choice. 
    - To exit press e(xit) or q(uit).
    - To save press s(ave).
    - If cheats are on you can go through the story of the game with p(revious) and n(ext)
    
    Press any key to exit tutorial.
    TUTORIAL
    $stdout.print(tutorial_text)
    $stdin.getch
  end

  def self.select_from(options, selected, game_state)
    system("clear")
    for y in 0...8 do
      for x in 0...8 do
        piece_text, piece_color = get_piece_render(y, x, options, selected, game_state)
        background_color = get_background_color(y, x, options, selected, game_state)
        render_block(y, x, piece_text, piece_color, background_color)
      end
      print("\n\n")
    end
  end

  def self.get_background_color(y, x, options, selected, game_state)
    option_color = "\e[48;2;0;180;216m"
    selected_color = "\e[48;2;0;119;182m"
    piece = game_state[:board].board[y][x]
    if game_state[:board].selected == [y, x] then
      return selected_color
    elsif piece == options[selected] then
      return option_color
    else
      (y+x)%2 == 0 ? "\e[47m" : "\e[40m"
    end
  end

  def self.get_piece_render(y, x, options, selected, game_state)
    piece_id = {"P" => :pawn, "R" => :rook, "H" => :knight, "B" => :bishop, "Q" => :queen, "K" => :king}
    white_color = "\e[38;5;250m"
    black_color = "\e[38;5;240m"
    option_color = "\e[38;2;172;216;167m"
    selected_color = "\e[38;2;70;146;60m"
    piece = game_state[:board].board[y][x]
    if !piece.nil? then
        piece_text = PIECES[piece_id[piece.id[0]]]
        piece_color = piece.id[2] == "W" ? white_color : black_color
        if options.include?([y, x]) then
          copy_color = option_color
          copy_color[2] = '4'
          piece_color += copy_color
          if options[selected] == [y, x] then
            copy_color = selected_color
            copy_color[2] = '4'
            piece_color += copy_color
          end
        end
    else
      if options.include?([y, x]) then
        piece_text = PIECES[:move]
        piece_color = option_color
        if options[selected] == [y, x] then
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

  def self.end_game(winner)
    system("clear")
    $stdout.print("    Game Over", "\n")
    if ["W", "B"].include?(winner) then
      piece = winner == "W" ? "♔" : "♚"
      $stdout.print("    Player #{piece} won!", "\n")
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