import csfml
import GameLogic

var window = newRenderWindow(videoMode(800, 600), "Tetris", WindowStyle.Titlebar|WindowStyle.Close)
window.keyRepeatEnabled = false

while window.open:
  var event: Event

  while window.pollEvent event:
    handleInput(event, window)

  window.clear(color(50, 50, 50, 255))

  runGameLoop(window)

  window.display()