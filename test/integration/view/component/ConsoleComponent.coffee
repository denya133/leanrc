RC = require 'RC'
EventEmitter = require 'events'

module.exports = (TestApp) ->
  class TestApp::ConsoleComponent extends RC::CoreObject
    @inheritProtected()
    @Module: TestApp

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
        console.log 'TODO: start animate robot'

    @public subscribeEvent: Function,
      default: (eventName, callback) ->
        @[ipoEventEmitter]?.on eventName, callback

    @public unsubscribeEvent: Function,
      default: (eventName, callback) ->
        if callback?
          @[ipoEventEmitter]?.removeListener eventName, callback
        else
          @[ipoEventEmitter]?.removeAllListeners eventName

    constructor: ->
      @[ipoEventEmitter] = new EventEmitter


  TestApp::ConsoleComponent.initialize()
