
EventEmitter = require 'events'

module.exports = (Module) ->
  {
    EventEmitterT, PointerT
    FuncG, SampleG, MaybeG
    CoreObject
  } = Module.NS

  class ConsoleComponent extends CoreObject
    @inheritProtected()
    @module Module

    @public @static ANIMATE_ROBOT_EVENT: String,
      default: 'animateRobotEvent'

    ipoEventEmitter = PointerT @private eventEmitter: EventEmitterT
    ipoInstance = PointerT @private instance: MaybeG(SampleG ConsoleComponent)

    @public @static getInstance: FuncG([], SampleG ConsoleComponent),
      default: ->
        unless @[ipoInstance]?
          @[ipoInstance] = @new()
        @[ipoInstance]

    @public writeMessages: Function,
      default: (messages...) ->
        # Commented out to prevent terminal pollution
        # console.log messages...
        return

    @public startAnimateRobot: Function,
      default: ->
        @[ipoEventEmitter].emit ConsoleComponent.ANIMATE_ROBOT_EVENT
        return

    @public subscribeEvent: Function,
      default: (eventName, callback) ->
        @[ipoEventEmitter].on eventName, callback
        return

    @public unsubscribeEvent: Function,
      default: (eventName, callback) ->
        if callback?
          @[ipoEventEmitter].removeListener eventName, callback
        else
          @[ipoEventEmitter].removeAllListeners eventName
        return

    constructor: (args...) ->
      super args...
      @[ipoEventEmitter] = new EventEmitter
      return


    @initialize()
