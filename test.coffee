Cylon = require 'cylon'

Cylon.robot
  connection: { name: 'leapmotion', adaptor: 'leapmotion', port: '127.0.0.1:6437' }
  device: { name: 'leapmotion', driver: 'leapmotion' }

  work: (my) ->
    my.leapmotion.on 'connect', ->
      Logger.info "Connected"

    my.leapmotion.on 'start', ->
      Logger.info "Started"

    my.leapmotion.on 'gesture', (payload) ->
      if payload.type == 'keyTap'
        console.log
          handId: payload.handIds
          pointableId: payload.pointableIds

.start()
