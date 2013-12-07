firmata = require 'firmata'
coffee  = require("coffee-script")
_ = require('underscore')

arduinoPort = process.argv[2]
console.log(arduinoPort)
arduinoConnected = false

board = new firmata.Board arduinoPort, ->
  console.log("Board connected")
  servos.map (pin) ->
    board.pinMode pin, board.MODES.PWM
    board.analogWrite(pin, 0)
  song()

servos = [6,9,10]

fingersToPin =
  3: 9
  2: 6
  1: 10

tappers = []

[0..4].map (finger) ->
  tapIt = (pin) ->
    console.log("Write servoPin : #{pin} for finger: #{finger}")
    board.analogWrite(pin, 10)
    reset = () -> board.analogWrite(pin, 0)
    setTimeout(reset, 50)
  tappers[finger] = _.debounce(tapIt, 55)

e = -> tappers[3](fingersToPin[3])
d = -> tappers[2](fingersToPin[2])
c = -> tappers[1](fingersToPin[1])

one = 500
two = one * 2
song = () ->
  time = 0
  setTimeout(e, time += one)
  setTimeout(d, time += one)
  setTimeout(c, time += one)
  setTimeout(d, time += one)

  setTimeout(e, time += one)
  setTimeout(e, time += one)
  setTimeout(e, time += one)

  setTimeout(d, time += two)
  setTimeout(d, time += one)
  setTimeout(d, time += one)

  setTimeout(e, time += two)
  setTimeout(e, time += one)
  setTimeout(e, time += one)

  setTimeout(e, time += two)
  setTimeout(d, time += one)
  setTimeout(c, time += one)
  setTimeout(d, time += one)

  setTimeout(e, time += one)
  setTimeout(e, time += one)
  setTimeout(e, time += one)

  setTimeout(e, time += one)
  setTimeout(d, time += one)
  setTimeout(d, time += one)
  setTimeout(e, time += one)
  setTimeout(d, time += one)
  setTimeout(c, time += one)
