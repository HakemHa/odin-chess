Refactor objectives:
- State is passed instead of directly accessed DONE
- play game and checkmate are broken down DONE
- Game state consists of board, turn, story DONE
- Modify pieces to receive entire game state DONE
- Pawn turns into queen (in execute move) DONE
- Make get_valid_moves consider check position DONE