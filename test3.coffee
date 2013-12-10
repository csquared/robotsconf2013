cylon = require 'cylon'
firmata = require 'firmata'
coffee  = require("coffee-script")
sprintf = require("sprintf")
_ = require('underscore')

arduinoPort = process.argv[2]
console.log(arduinoPort)
arduinoConnected = false

board = new firmata.Board arduinoPort, ->
  console.log("Board connected")
  servos.map (pin) ->
    board.pinMode pin, board.MODES.PWM
    board.analogWrite(pin, 0)
  arduinoConnected = true

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


finger_order = []
known_fingers = {}
finger_death = {}

detect_finger_down = (fingers) ->
  sorted = []
  for id, finger of fingers
    sorted.push coffee.helpers.merge(finger, id:id)
  sorted = sorted.sort (a, b) ->
    a.position[0] - b.position[0]
  down = []
  for idx, finger of sorted
    down.push(idx) if finger.position[1] < 100
  down

cylon.robot
  connection: { name: 'leapmotion', adaptor: 'leapmotion', port: '127.0.0.1:6437' }
  device: { name: 'leapmotion', driver: 'leapmotion' }

  work: (my) ->
    my.leapmotion.on 'connect', ->
      Logger.info "Leap Connected"

    my.leapmotion.on 'start', ->
      Logger.info "Leap Started"

    my.leapmotion.on 'gesture', (payload) ->
      return unless payload.type == 'keyTap'
      console.log
        handId: payload.handIds
        pointableId: payload.pointableIds

.start()

###
#
    my.leapmotion.on "pointable", (pointable) ->
      clearTimeout finger_death[pointable.id] if finger_death[pointable.id]
      finger_death[pointable.id] = setTimeout((-> delete known_fingers[pointable.id]), 200)
      known_fingers[pointable.id] = position:pointable.tipPosition
      downFingers = detect_finger_down(known_fingers)
      #console.log downFingers

      if arduinoConnected
        for finger in downFingers
          if pin = fingersToPin[finger]
            tappers[finger](pin)
            tapIt = () ->
              console.log("Write servoPin : #{pin}")
              board.analogWrite(pin, 10)
              reset = () -> board.analogWrite(pin, 0)
              setTimeout(reset, 50)
            debouncedTapIt = _.debounce(tapIt, 250)
            debouncedTapIt()

    my.leapmotion.on 'gesture', (payload) ->
      return unless payload.type == 'keyTap'
      console.log
        handId: payload.handIds
        pointableId: payload.pointableIds

      if arduinoConnected
        console.log("Write servoPin")
        board.analogWrite(servoPin, 10)
        reset = () -> board.analogWrite(servoPin, 0)
        setTimeout(reset, 50)
###

