# LeanRC = require.main.require 'lib'

module.exports = (Module) ->
  class AppFacade extends Module.NS.Facade
    @inheritProtected()
    @module Module

    vpbIsInitialized = @private isInitialized: Boolean,
      default: no
    cphInstanceMap  = @protected @static instanceMap: Object,
      default: {}

    @public startup: Function,
      default: ->
        unless @[vpbIsInitialized]
          @[vpbIsInitialized] = yes
          @registerCommand Module.NS.STARTUP, Module.NS.StartupCommand
          @sendNotification Module.NS.STARTUP

    @public finish: Function,
      default: ->
        @removeMediator  Module.NS.ConsoleComponentMediator::CONSOLE_MEDIATOR

    @public @static getInstance: Function,
      default: (asKey)->
        vhInstanceMap = Module.NS.Facade[cphInstanceMap]
        unless vhInstanceMap[asKey]?
          vhInstanceMap[asKey] = Module.NS.AppFacade.new asKey
        vhInstanceMap[asKey]

  AppFacade.initialize()
