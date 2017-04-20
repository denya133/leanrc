
EventEmitter = require 'events'

module.exports = (Module) ->
  class ConsoleComponent extends Module::CoreObject
    @inheritProtected()
    @module Module

    @public @static ANIMATE_ROBOT_EVENT: String,
      default: 'animateRobotEvent'

    ipoEventEmitter = @private eventEmitter: EventEmitter,
      default: null
    ipoInstance = @private instance: ConsoleComponent,
      default: null

    @public @static getInstance: Function,
      default: ->
        unless @[ipoInstance]?
          @[ipoInstance] = ConsoleComponent.new()
        @[ipoInstance]

    @public writeMessages: Function,
      default: (messages...) ->
        console.log messages...

    @public startAnimateRobot: Function,
      default: ->
        @[ipoEventEmitter].emit ConsoleComponent.ANIMATE_ROBOT_EVENT

    @public subscribeEvent: Function,
      default: (eventName, callback) ->
        @[ipoEventEmitter].on eventName, callback

    @public unsubscribeEvent: Function,
      default: (eventName, callback) ->
        if callback?
          @[ipoEventEmitter].removeListener eventName, callback
        else
          @[ipoEventEmitter].removeAllListeners eventName

    constructor: ->
      @[ipoEventEmitter] = new EventEmitter


  ConsoleComponent.initialize()
