RC = require 'RC'
EventEmitter = require 'events'

module.exports = (TestApp) ->
  class TestApp::ConsoleComponent extends RC::CoreObject
    @inheritProtected()
    @Module: TestApp

    @public @static ANIMATE_ROBOT_EVENT: String,
      default: 'animateRobotEvent'

    ipoEventEmitter = @private eventEmitter: EventEmitter,
      default: null
    ipoInstance = @private instance: TestApp::ConsoleComponent,
      default: null

    @public @static getInstance: Function,
      default: ->
        unless @[ipoInstance]?
          @[ipoInstance] = TestApp::ConsoleComponent.new()
        @[ipoInstance]

    @public writeMessages: Function,
      default: (messages...) ->
        console.log messages...

    @public startAnimateRobot: Function,
      default: ->
        @[ipoEventEmitter].emit TestApp::ConsoleComponent.ANIMATE_ROBOT_EVENT

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


  TestApp::ConsoleComponent.initialize()
