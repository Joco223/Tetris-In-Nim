import csfml

type tetromino = object
  positions*: seq[seq[Vector2i]]
  sizes*: seq[Vector2i]
  position_count*: int
  color*: Color

proc drawTetromino*(x: tetromino, cur_position, tile_size, start_x, start_y, alpha: int, window: RenderWindow, tile_sprite: var Sprite, normalized: bool = false) =
  if not normalized:
    for piece in x.positions[cur_position]:
      tile_sprite.position = vec2(start_x + piece.x*tile_size, start_y + piece.y*tile_size)
      tile_sprite.color = color((int)x.color.r, (int)x.color.g, (int)x.color.b, alpha)
      window.draw(tile_sprite)
  else:
    var offset_x = 0
    var offset_y = 0
    for piece in x.positions[cur_position]:
      if piece.x < offset_x: offset_x = piece.x
      if piece.y < offset_y: offset_y = piece.y

    for piece in x.positions[cur_position]:
      tile_sprite.position = vec2(start_x + piece.x*tile_size + offset_x, start_y + piece.y*tile_size + offset_y)
      tile_sprite.color = color((int)x.color.r, (int)x.color.g, (int)x.color.b, alpha)
      window.draw(tile_sprite)

var tetromino_I = tetromino()
tetromino_I.positions.add(@[vec2(-1, 0), vec2(0, 0), vec2(1, 0), vec2(2, 0)])
tetromino_I.positions.add(@[vec2(0, -1), vec2(0, 0), vec2(0, 1), vec2(0, 2)])
tetromino_I.sizes.add(vec2(4, 1))
tetromino_I.sizes.add(vec2(1, 4))
tetromino_I.position_count = 2
tetromino_I.color = color(0, 240, 240, 255)

var tetromino_L = tetromino()
tetromino_L.positions.add(@[vec2(-1, -1), vec2(-1, 0), vec2(0, 0), vec2( 1, 0)])
tetromino_L.positions.add(@[vec2(0 , -1), vec2(1, -1), vec2(0, 0), vec2( 0, 1)])
tetromino_L.positions.add(@[vec2(-1,  0), vec2(0,  0), vec2(1, 0), vec2( 1, 1)])
tetromino_L.positions.add(@[vec2(0 , -1), vec2(0,  0), vec2(0, 1), vec2(-1, 1)])
tetromino_L.sizes.add(vec2(4, 2))
tetromino_L.sizes.add(vec2(2, 4))
tetromino_L.sizes.add(vec2(4, 2))
tetromino_L.sizes.add(vec2(2, 4))
tetromino_L.position_count = 4
tetromino_L.color = color(0, 0, 240, 255)

var tetromino_J = tetromino()
tetromino_J.positions.add(@[vec2(1, -1), vec2( 1,  0), vec2( 0, 0), vec2(-1, 0)])
tetromino_J.positions.add(@[vec2(0, -1), vec2( 0,  0), vec2( 0, 1), vec2( 1, 1)])
tetromino_J.positions.add(@[vec2(1,  0), vec2( 0,  0), vec2(-1, 0), vec2(-1, 1)])
tetromino_J.positions.add(@[vec2(0, -1), vec2(-1, -1), vec2( 0, 0), vec2( 0, 1)])
tetromino_J.sizes.add(vec2(4, 2))
tetromino_J.sizes.add(vec2(2, 4))
tetromino_J.sizes.add(vec2(4, 2))
tetromino_J.sizes.add(vec2(2, 4))
tetromino_J.position_count = 4
tetromino_J.color = color(240, 160, 0, 255)

var tetromino_O = tetromino()
tetromino_O.positions.add(@[vec2(0, 0), vec2(1, 0), vec2(0, 1), vec2(1, 1)])
tetromino_O.sizes.add(vec2(2, 2))
tetromino_O.position_count = 1
tetromino_O.color = color(240, 240, 0, 255)

var tetromino_S = tetromino()
tetromino_S.positions.add(@[vec2(0, 0), vec2(1, 0), vec2(-1, 1), vec2( 0,  1)])
tetromino_S.positions.add(@[vec2(0, 0), vec2(0, 1), vec2(-1, 0), vec2(-1, -1)])
tetromino_S.sizes.add(vec2(3, 2))
tetromino_S.sizes.add(vec2(2, 3))
tetromino_S.position_count = 2
tetromino_S.color = color(0, 240, 0, 255)

var tetromino_Z = tetromino()
tetromino_Z.positions.add(@[vec2(0, 0), vec2(-1,  0), vec2( 1, 1), vec2( 0, 1)])
tetromino_Z.positions.add(@[vec2(0, 0), vec2( 0, -1), vec2(-1, 0), vec2(-1, 1)])
tetromino_Z.sizes.add(vec2(3, 2))
tetromino_Z.sizes.add(vec2(2, 3))
tetromino_Z.position_count = 2
tetromino_Z.color = color(240, 0, 0, 255)

var tetromino_T = tetromino()
tetromino_T.positions.add(@[vec2(0, 0), vec2( 0,  1), vec2(-1,  1), vec2( 1,  1)])
tetromino_T.positions.add(@[vec2(0, 0), vec2(-1,  0), vec2(-1, -1), vec2(-1,  1)])
tetromino_T.positions.add(@[vec2(0, 0), vec2( 0, -1), vec2( 1, -1), vec2(-1, -1)])
tetromino_T.positions.add(@[vec2(0, 0), vec2( 1,  0), vec2( 1,  1), vec2( 1, -1)])
tetromino_T.sizes.add(vec2(3, 2))
tetromino_T.sizes.add(vec2(2, 3))
tetromino_T.sizes.add(vec2(3, 2))
tetromino_T.sizes.add(vec2(2, 3))
tetromino_T.position_count = 4
tetromino_T.color = color(160, 0, 240, 255)

var tetromino_pieces* = newSeq[tetromino]()
tetromino_pieces.add(tetromino_I)
tetromino_pieces.add(tetromino_L)
tetromino_pieces.add(tetromino_J)
tetromino_pieces.add(tetromino_O)
tetromino_pieces.add(tetromino_S)
tetromino_pieces.add(tetromino_Z)
tetromino_pieces.add(tetromino_T)