Cylon = require 'cylon'
firmata = require 'firmata'

arduinoPort = process.argv[2]
console.log(arduinoPort)
arduinoConnected = false

servoPin = 11

board = new firmata.Board arduinoPort, ->
  console.log("Board connected")
  board.pinMode servoPin, board.MODES.PWM
  board.analogWrite(servoPin, 0)
  arduinoConnected = true

Cylon.robot
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

      if arduinoConnected
        console.log("Write servoPin")
        board.analogWrite(servoPin, 10)
        reset = () -> board.analogWrite(servoPin, 0)
        setTimeout(reset, 50)

.start()
