import csfml
import strutils
import PlayingField
import PlayingPieces

var tile_texture = newTexture("assets/tile.png")
var tile_sprite = newSprite(tile_texture)
var defualt_tile_color = color(255, 255, 255, 100)
tile_sprite.color = defualt_tile_color

var default_font = newFont("assets/arial.ttf")
var next_piece_text = newText("Next piece", default_font)
next_piece_text.characterSize = 20
next_piece_text.position = vec2(background_start.x-6*tile_size, background_start.y-tile_size)
next_piece_text.outlineThickness = 2
next_piece_text.outlineColor = color(0, 0, 0, 100)

var score_text = newText("Score:\n", default_font)
score_text.characterSize = 20
score_text.outlineThickness = 2
score_text.outlineColor = color(0, 0, 0, 100)

var line_text = newText("Lines:\n", default_font)
line_text.characterSize = 20
line_text.outlineThickness = 2
line_text.outlineColor = color(0, 0, 0, 100)

var combo_text = newText("Combo:\n", default_font)
combo_text.characterSize = 20
combo_text.outlineThickness = 2
combo_text.outlineColor = color(0, 0, 0, 100)

var game_over_text = newText("GAME OVER", default_font)
game_over_text.characterSize = 50
game_over_text.position = vec2(400 - (int)(game_over_text.globalBounds().width) div 2, 300 - (int)(game_over_text.globalBounds().height) div 2)
game_over_text.outlineThickness = 3
game_over_text.outlineColor = color(0, 0, 0, 200)

var instructions_text = newText("Instructions:\nLeft: Move left\nRight: Move right\nDown: Fall faster\nUp: Place imidately\nR: Rotate\nX: Quit", default_font)
instructions_text.characterSize = 20
instructions_text.outlineThickness = 2
instructions_text.outlineColor = color(0, 0, 0, 100)
instructions_text.position = vec2(background_start.x - tile_size - (int)instructions_text.globalBounds().width, background_start.y + 5*tile_size)

var highscores_text = newText("Highscores:", default_font)
highscores_text.characterSize = 20
highscores_text.outlineThickness = 2
highscores_text.outlineColor = color(0, 0, 0, 100)
highscores_text.position = vec2(background_start.x + (background_size.x*tile_size) + tile_size, background_start.y+tile_size)

var highscores_numbers = newText("No.\n#1\n#2\n#3\n#4\n#5\n#6\n#7\n#8\n#9\n#10", default_font)
highscores_numbers.characterSize = 20
highscores_numbers.outlineThickness = 2
highscores_numbers.outlineColor = color(0, 0, 0, 100)
highscores_numbers.position = vec2(background_start.x + (background_size.x*tile_size) + tile_size, background_start.y+2*tile_size)

var highscores_scores = newText("Score:\n", default_font)
highscores_scores.characterSize = 20
highscores_scores.outlineThickness = 2
highscores_scores.outlineColor = color(0, 0, 0, 100)
highscores_scores.position = vec2(background_start.x + (background_size.x*tile_size) + 2*tile_size + (int)(highscores_numbers.globalBounds().width), background_start.y+2*tile_size)

var highscores_lines = newText("Lines:\n", default_font)
highscores_lines.characterSize = 20
highscores_lines.outlineThickness = 2
highscores_lines.outlineColor = color(0, 0, 0, 100)

proc drawBackground*(window: RenderWindow) =
  for x in countup(0, background_size.x-1):
    for y in countup(0, background_size.y-1):
      tile_sprite.position = vec2(background_start.x + 24*x, background_start.y + 24*y)
      if background_tiles[x + y*background_size.x].state:
        tile_sprite.color = background_tiles[x + y*background_size.x].color
      window.draw(tile_sprite)
      tile_sprite.color = color(255, 255, 255, 100)

proc drawTetrominoPrediction(window: RenderWindow) =
  var index = 1
  while not obstructedDown(index):
    inc(index)
    if obstructedDown(index):
      drawTetromino(current_tetromino, current_tetromino_pos, tile_size, background_start.x+tetromino_position.x*tile_size, background_start.y+(tetromino_position.y+index-1)*tile_size, 100, window, tile_sprite)
  
  tile_sprite.color = color(255, 255, 255, 100)

proc drawCurrentTetromino*(window: RenderWindow) =
  drawTetromino(current_tetromino, current_tetromino_pos, tile_size, background_start.x+tetromino_position.x*tile_size, background_start.y+tetromino_position.y*tile_size, 255, window, tile_sprite)
  
  #Next tetromino
  if next_tetromino_index == 1 or next_tetromino_index == 2:
    drawTetromino(tetromino_pieces[next_tetromino_index], 0, tile_size, background_start.x-4*tile_size, background_start.y+2*tile_size, 255, window, tile_sprite, true)
  else:
    drawTetromino(tetromino_pieces[next_tetromino_index], 0, tile_size, background_start.x-4*tile_size, background_start.y+tile_size, 255, window, tile_sprite, true)
  window.draw(next_piece_text)

  drawTetrominoPrediction(window)

proc drawCurrentScore*(score: int, window: RenderWindow) =
  score_text.str = "Score:\n" & center($score, 6)
  score_text.position = vec2(background_start.x, background_start.y-(int)(2.2*(float)tile_size))
  window.draw(score_text)

proc drawCurrentLines*(lines: int, window: RenderWindow) = 
  line_text.str = "Lines:\n" & center($lines, 6)
  line_text.position = vec2(background_start.x + (background_size.x*tile_size) - (int)line_text.globalBounds().width, background_start.y-(int)(2.2*(float)tile_size))
  window.draw(line_text)

proc drawCurrentCombo*(combo: int, window: RenderWindow) = 
  combo_text.str = "Combo:\n" & center($combo & "x", 6)
  combo_text.position = vec2(400 - (int)(combo_text.globalBounds().width) div 2, background_start.y-(int)(2.2*(float)tile_size)) 
  window.draw(combo_text)

proc drawGameOver*(window: RenderWindow) =
  window.draw(game_over_text)

proc drawInstructions*(window: RenderWindow) =
  window.draw(instructions_text)

proc drawHighScores*(window: RenderWindow, scores, lines: openArray[int]) =
  window.draw(highscores_text)
  window.draw(highscores_numbers)

  var index = 0
  var scores_string = "Score:\n"
  for score in scores:
    if index > 9:
      break
    else:
      scores_string = scores_string & $score & "\n"

  highscores_scores.str = scores_string
  window.draw(highscores_scores)

  highscores_lines.position = vec2(background_start.x + (background_size.x*tile_size) + 3*tile_size + (int)(highscores_numbers.globalBounds().width) + (int)(highscores_scores.globalBounds().width), background_start.y+2*tile_size)

  index = 0
  var lines_string = "Lines:\n"
  for line in lines:
    if index > 9:
      break
    else:
      lines_string = lines_string & $line & "\n"

  highscores_lines.str = lines_string
  window.draw(highscores_lines)