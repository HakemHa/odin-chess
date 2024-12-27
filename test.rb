require_relative "./lib/Game"

game_state = {}
Game.create_game_state(game_state)
Render.mini_board(game_state, {}, nil, 0, nil, 0, [0, 10])
