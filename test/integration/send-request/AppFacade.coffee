# LeanRC = require.main.require 'lib'

module.exports = (Module) ->
  class AppFacade extends Module::Facade
    @inheritProtected()
    @Module: Module

    vpbIsInitialized = @private isInitialized: Boolean,
      default: no
    cphInstanceMap  = @protected @static instanceMap: Object,
      default: {}

    @public startup: Function,
      default: ->
        unless @[vpbIsInitialized]
          @[vpbIsInitialized] = yes
          @registerCommand Module::STARTUP, Module::StartupCommand
          @sendNotification Module::STARTUP

    @public finish: Function,
      default: ->
        @removeMediator  Module::ConsoleComponentMediator::CONSOLE_MEDIATOR

    @public @static getInstance: Function,
      default: (asKey)->
        vhInstanceMap = Module::Facade[cphInstanceMap]
        unless vhInstanceMap[asKey]?
          vhInstanceMap[asKey] = Module::AppFacade.new asKey
        vhInstanceMap[asKey]

  AppFacade.initialize()
