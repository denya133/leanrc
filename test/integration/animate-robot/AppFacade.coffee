LeanRC = require.main.require 'lib'

module.exports = (TestApp) ->
  class TestApp::AppFacade extends LeanRC::Facade
    @inheritProtected()
    @Module: TestApp

    vpbIsInitialized = @private isInitialized: Boolean,
      default: no
    cphInstanceMap  = @protected @static instanceMap: Object,
      default: {}

    @public startup: Function,
      default: ->
        unless @[vpbIsInitialized]
          @[vpbIsInitialized] = yes
          @registerCommand TestApp::AppConstants.STARTUP, TestApp::StartupCommand
          @sendNotification TestApp::AppConstants.STARTUP

    @public finish: Function,
      default: ->
        @removeMediator  TestApp::ConsoleComponentMediator.CONSOLE_MEDIATOR

    @public @static getInstance: Function,
      default: (asKey)->
        vhInstanceMap = LeanRC::Facade[cphInstanceMap]
        unless vhInstanceMap[asKey]?
          vhInstanceMap[asKey] = TestApp::AppFacade.new asKey
        vhInstanceMap[asKey]

  TestApp::AppFacade.initialize()
