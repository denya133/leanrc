RC      = require 'RC'
LeanRC  = require 'LeanRC'

module.exports = (Module) ->
  class Module::ApplicationFacade extends LeanRC::Facade
    @inheritProtected()
    @Module: Module

    vpbIsInitialized = @private isInitialized: Boolean,
      default: no
    cphInstanceMap  = @protected @static instanceMap: Object,
      default: {}

    @protected initializeController: Function,
      default: (args...)->
        @super args...
        @registerCommand Module::Constants.STARTUP, Module::StartupCommand
        # ... здесь могут быть регистрации и других команд

    @public startup: Function,
      default: (aoApplication)->
        unless @[vpbIsInitialized]
          @[vpbIsInitialized] = yes
          @sendNotification Module::Constants.STARTUP, aoApplication

    @public @static getInstance: Function,
      default: (asKey)->
        vhInstanceMap = LeanRC::Facade[cphInstanceMap]
        unless vhInstanceMap[asKey]?
          vhInstanceMap[asKey] = Module::ApplicationFacade.new asKey
        vhInstanceMap[asKey]


  Module::ApplicationFacade.initialize()
