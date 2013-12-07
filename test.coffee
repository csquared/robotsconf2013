coffee  = require("coffee-script")
cylon   = require("cylon")
sprintf = require("sprintf")

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
      Logger.info "Connected"

    my.leapmotion.on 'start', ->
      Logger.info "Started"

    my.leapmotion.on "pointable", (pointable) ->
      clearTimeout finger_death[pointable.id] if finger_death[pointable.id]
      finger_death[pointable.id] = setTimeout((-> delete known_fingers[pointable.id]), 200)
      known_fingers[pointable.id] = position:pointable.tipPosition
      console.log detect_finger_down known_fingers

      # console.log JSON.stringify(pointable)
      # console.log "known_fingers", known_fingers
      # console.log "#{known_fingers.length} #{pointable.handId} #{pointable.id} #{pointable.tipPosition}"

    # my.leapmotion.on 'gesture', (payload) ->
    #   console.log "payload.type", payload.type
      # if payload.type == 'keyTap'
      #   console.log
      #     handId: payload.handIds
      #     pointableId: payload.pointableIds

.start()
