
EventEmitter = require 'events'

module.exports = (Module) ->
  class Module::ConsoleComponent extends Module::CoreObject
    @inheritProtected()
    @Module: Module

    @const MESSAGE_WRITTEN: 'messageWritten'
    @const SEND_REQUEST_EVENT: 'sendRequestEvent'

    ipoEventEmitter = @private eventEmitter: EventEmitter,
      default: null
    ipoInstance = @private instance: Module::ConsoleComponent,
      default: null

    @public @static getInstance: Function,
      default: ->
        unless @[ipoInstance]?
          @[ipoInstance] = Module::ConsoleComponent.new()
        @[ipoInstance]

    @public writeMessages: Function,
      default: (messages...) ->
        console.log messages...
        @[ipoEventEmitter].emit Module::ConsoleComponent::MESSAGE_WRITTEN

    @public sendRequest: Function,
      default: ->
        @[ipoEventEmitter].emit Module::ConsoleComponent::SEND_REQUEST_EVENT

    @public subscribeEvent: Function,
      default: (eventName, callback) ->
        @[ipoEventEmitter].on eventName, callback

    @public subscribeEventOnce: Function,
      default: (eventName, callback) ->
        @[ipoEventEmitter].once eventName, callback

    @public unsubscribeEvent: Function,
      default: (eventName, callback) ->
        if callback?
          @[ipoEventEmitter].removeListener eventName, callback
        else
          @[ipoEventEmitter].removeAllListeners eventName

    constructor: ->
      @[ipoEventEmitter] = new EventEmitter


  Module::ConsoleComponent.initialize()
