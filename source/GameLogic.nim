import csfml
import algorithm
import PlayingField
import Graphics
import JSONDatabase

var fastForwardPressed = false
var alive = true
var saved_highscore = false

var current_score = 0
var current_lines = 0
var current_combo = 1

var highscores_file = loadDatabase("highscores.json")
var highscores_scores = readKeys[int](highscores_file, "scores")
var highscores_lines = readKeys[int](highscores_file, "lines")

proc handleScore(cleared_line_count: int) =
  case cleared_line_count
    of 1:
      current_score += 100 * current_combo
      inc(current_combo)
    of 2:
      current_score += 200 * current_combo
      inc(current_combo)
    of 3:
      current_score += 400 * current_combo
      inc(current_combo)
    of 4:
      current_score += 800 * current_combo
      inc(current_combo)
    else:
      current_score += 0
      current_combo = 1
  current_lines += cleared_line_count

proc handleInput*(event: Event, window: var RenderWindow) =
  if event.kind == EventType.Closed:
    saveDatabase(highscores_file)
    window.close()
  elif event.kind == EventType.KeyPressed and alive:
    case event.key.code
      of KeyCode.Left:  moveLeft()
      of KeyCode.Right: moveRight()
      of KeyCode.Down:  goFast()

      of KeyCode.Up: fastForwardPressed = true
      of KeyCode.R: rotateTetromino()

      else: write(stdout, "")
  elif event.kind == EventType.KeyReleased and alive:
    case event.key.code
      of KeyCode.Down:  goSlow()
      else: write(stdout, "")
  elif event.kind == EventType.KeyPressed and not alive:
    case event.key.code
      of KeyCode.X: window.close()
      else: write(stdout, "")

proc runGameLoop*(window: var RenderWindow) =
  if alive:
    if fastForwardPressed:
      fastForward()
      fastForwardPressed = false;
      handleScore(updateBackground())
    else:
      if updateTetromino():
        handleScore(updateBackground())

  drawCurrentScore(current_score, window)
  drawCurrentLines(current_lines, window)
  drawCurrentCombo(current_combo, window)
  drawHighscores(window, highscores_scores, highscores_lines)

  drawInstructions(window)

  drawBackground(window)

  alive = canSpawn()

  if alive:
    drawCurrentTetromino(window)
  else:
    drawGameOver(window)
    if not saved_highscore:
      if current_score != 0:
        highscores_scores.add(current_score)
        highscores_lines.add(current_lines)
        highscores_scores.sort(Descending)
        highscores_lines.sort(Descending)
        discard writeKeys[int](highscores_file, "scores", highscores_scores)
        discard writeKeys[int](highscores_file, "lines", highscores_lines)
        saveDatabase(highscores_file)

      saved_highscore = true