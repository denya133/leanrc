LeanRC = require.main.require 'lib'

module.exports = (RequestApp) ->
  class RequestApp::AppFacade extends LeanRC::Facade
    @inheritProtected()
    @Module: RequestApp

    vpbIsInitialized = @private isInitialized: Boolean,
      default: no
    cphInstanceMap  = @protected @static instanceMap: Object,
      default: {}

    @public startup: Function,
      default: ->
        unless @[vpbIsInitialized]
          @[vpbIsInitialized] = yes
          @registerCommand RequestApp::AppConstants.STARTUP, RequestApp::StartupCommand
          @sendNotification RequestApp::AppConstants.STARTUP

    @public finish: Function,
      default: ->
        @removeMediator  RequestApp::ConsoleComponentMediator.CONSOLE_MEDIATOR

    @public @static getInstance: Function,
      default: (asKey)->
        vhInstanceMap = LeanRC::Facade[cphInstanceMap]
        unless vhInstanceMap[asKey]?
          vhInstanceMap[asKey] = RequestApp::AppFacade.new asKey
        vhInstanceMap[asKey]

  RequestApp::AppFacade.initialize()
