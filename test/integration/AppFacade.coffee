LeanRC = require.main.require 'lib'

module.exports = (TestApp) ->
  class TestApp::AppFacade extends LeanRC::Facade
    @inheritProtected()
    @Module: TestApp

    vpbIsInitialized = @private isInitialized: Boolean,
      default: no
    cphInstanceMap  = @private @static instanceMap: Object,
      default: {}

    @public startup: Function,
      default: ->
        unless @[vpbIsInitialized]
          @[vpbIsInitialized] = yes
          @registerCommand TestApp::AppConstants.STARTUP, TestApp::StartupCommand
          @sendNotification TestApp::AppConstants.STARTUP

    @public @static getInstance: Function,
      default: (asKey)->
        unless LeanRC::Facade[cphInstanceMap][asKey]?
          LeanRC::Facade[cphInstanceMap][asKey] = TestApp::AppFacade.new asKey
        LeanRC::Facade[cphInstanceMap][asKey]

  TestApp::AppFacade.initialize()
