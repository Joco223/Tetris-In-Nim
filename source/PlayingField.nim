import csfml
import random
import PlayingPieces

randomize()

let background_start* = vec2(280, 60)
let background_size* = vec2(10, 20)
let tile_size* = 24

var tetromino_position* = vec2(5, 1)
var next_tetromino_index* = rand(tetromino_pieces.len()-1)
var current_tetromino_index* = rand(tetromino_pieces.len()-1)
var current_tetromino* = tetromino_pieces[current_tetromino_index]
var current_tetromino_pos* = 0

type background_tile = object
  color*: Color
  state*: bool

var background_tiles* = newSeq[background_tile]()
for x in countup(0, background_size.x-1):
  for y in countup(0, background_size.y-1):
    var tmp = background_tile()
    tmp.color = color(255, 255, 255, 255)
    tmp.state = false
    background_tiles.add(tmp)

var clock = newClock()
var move_pause = 750

var start = clock.elapsedTime().asMilliseconds()

proc obstructedDown*(offset: int, tetromino_index: int = current_tetromino_pos): bool =
  result = false
  for piece in current_tetromino.positions[tetromino_index]:
    if tetromino_position.y + piece.y + offset > background_size.y-1:
      result = true
      break
    
    if background_tiles[tetromino_position.x + piece.x + (tetromino_position.y + piece.y + offset)*background_size.x].state:
      result = true
      break

proc obstructedLeft*(offset, tetromino_index: int): bool =
  result = false
  for piece in current_tetromino.positions[tetromino_index]:
    if tetromino_position.x + piece.x - offset < 0:
      result = true
      break

    if background_tiles[tetromino_position.x + piece.x - offset + (tetromino_position.y + piece.y)*background_size.x].state:
      result = true
      break

proc moveLeft*(tetromino_index: int = current_tetromino_pos) =
  if not obstructedLeft(1, tetromino_index):
    tetromino_position.x -= 1
    if obstructedDown(1):
      start = clock.elapsedTime().asMilliseconds()

proc obstructedRight*(offset, tetromino_index: int): bool =
  result = false
  for piece in current_tetromino.positions[tetromino_index]:
    if tetromino_position.x + piece.x + offset > background_size.x-1:
      result = true
      break
    
    if background_tiles[tetromino_position.x + piece.x + offset + (tetromino_position.y + piece.y)*background_size.x].state:
      result = true
      break

proc moveRight*(tetromino_index: int = current_tetromino_pos) =
  if not obstructedRight(1, tetromino_index):
    tetromino_position.x += 1
    if obstructedDown(1):
      start = clock.elapsedTime().asMilliseconds()

proc goFast*() =
  move_pause = 100

proc goSlow*() =
  move_pause = 750

proc createNewTetromino() =
  for piece in current_tetromino.positions[current_tetromino_pos]:
    background_tiles[tetromino_position.x + piece.x + (tetromino_position.y + piece.y)*background_size.x].state = true
    background_tiles[tetromino_position.x + piece.x + (tetromino_position.y + piece.y)*background_size.x].color = current_tetromino.color

  current_tetromino_index = next_tetromino_index
  next_tetromino_index = rand(tetromino_pieces.len()-1)
  current_tetromino = tetromino_pieces[current_tetromino_index]
  current_tetromino_pos = 0

  tetromino_position.x = 5
  tetromino_position.y = 1

proc fastForward*() =
  var index = 1
  while not obstructedDown(index):
    inc(index)
    if obstructedDown(index):
      tetromino_position.y += (cint)index-1
      createNewTetromino()
      break

proc rotateTetromino*() =
  if current_tetromino.position_count > 0:
    var next_tetromino_pos = (current_tetromino_pos + 1) mod current_tetromino.position_count

    if not obstructedLeft(0, next_tetromino_pos) and not obstructedRight(0, next_tetromino_pos) and not obstructedDown(0, next_tetromino_pos):
      current_tetromino_pos = next_tetromino_pos
      if obstructedDown(1):
        start = clock.elapsedTime().asMilliseconds()

proc canSpawn*(): bool =
  result = not obstructedLeft(0, current_tetromino_pos)
  result = not obstructedRight(0, current_tetromino_pos)
  result = not obstructedDown(0)

proc updateTetromino*(): bool =
  if not obstructedDown(1):
    var current_time = clock.elapsedTime().asMilliseconds()
    if current_time - start > move_pause:
      inc(tetromino_position.y)
      start = current_time
    return false
  else:
    var current_time = clock.elapsedTime().asMilliseconds()
    if current_time - start > move_pause:
      start = current_time
      createNewTetromino()
    return true

proc updateBackground*(): int =
  var number_of_cleared_lines = 0
  for y in countup(0, background_size.y-1):
    var filled = true
    for x in countup(0, background_size.x-1):
      if not background_tiles[x + y * background_size.x].state:
        filled = false
        break
    
    if filled:
      for reverse_y in countdown(y-1, 0):
        for x in countup(0, background_size.x-1):
          background_tiles[x + (reverse_y+1)*background_size.x] = background_tiles[x + reverse_y*background_size.x]
      
      inc(number_of_cleared_lines)

  return number_of_cleared_lines