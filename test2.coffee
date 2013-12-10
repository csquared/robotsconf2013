coffee  = require("coffee-script")
firmata = require 'firmata'
leap    = require 'leapjs'
_       = require('underscore')

arduinoPort = process.argv[2]
arduinoConnected = false

fingersToPin =
  3: 9
  2: 6
  1: 10

if arduinoPort
  console.log "connecting to arduino at #{arduinoPort}"
  board = new firmata.Board arduinoPort, ->
    console.log("Board connected")
    for finger, pin of fingersToPin
      board.pinMode pin, board.MODES.PWM
      board.analogWrite(pin, 0)
    arduinoConnected = true

  tapIt = (finger) ->
    return unless arduinoConnected
    pin = fingersToPin[finger]
    return unless pin
    console.log("arduino=true pin=#{pin} finger=#{finger}")
    board.analogWrite(pin, 10)
    reset = () -> board.analogWrite(pin, 0)
    setTimeout(reset, 50)

else
  console.log "no arduino specified"
  tapIt = (finger) ->
    pin = fingersToPin[finger]
    console.log("pin=#{pin} finger=#{finger}")

controller = new leap.Controller(enableGestures: true)

controller.on 'connect', ->
  console.log "Leap connected"

controller.on 'frame', (frame) ->
  for gesture in frame.gestures
    controller.emit(gesture.type, gesture, frame)

controller.on 'keyTap', (tap, frame) ->
  fingerId = tap.pointableIds[0]
  handId = tap.handIds[0]
  hand = frame.handsMap[handId]
  sortedFingers = _.sortBy(hand.fingers, (finger) ->
    finger.stabilizedTipPosition[0])

  fingers = sortedFingers.map (finger) -> finger.id
  index   = fingers.indexOf(fingerId)

  tapIt(index)

controller.connect()
