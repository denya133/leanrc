RC = require 'RC'
EventEmitter = require 'events'

module.exports = (RequestApp) ->
  class RequestApp::ConsoleComponent extends RC::CoreObject
    @inheritProtected()
    @Module: RequestApp

    @public @static MESSAGE_WRITTEN: String,
      default: 'messageWritten'

    @public @static SEND_REQUEST_EVENT: String,
      default: 'sendRequestEvent'

    ipoEventEmitter = @private eventEmitter: EventEmitter,
      default: null
    ipoInstance = @private instance: RequestApp::ConsoleComponent,
      default: null

    @public @static getInstance: Function,
      default: ->
        unless @[ipoInstance]?
          @[ipoInstance] = RequestApp::ConsoleComponent.new()
        @[ipoInstance]

    @public writeMessages: Function,
      default: (messages...) ->
        console.log messages...
        @[ipoEventEmitter].emit RequestApp::ConsoleComponent.MESSAGE_WRITTEN

    @public sendRequest: Function,
      default: ->
        @[ipoEventEmitter].emit RequestApp::ConsoleComponent.SEND_REQUEST_EVENT

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


  RequestApp::ConsoleComponent.initialize()
