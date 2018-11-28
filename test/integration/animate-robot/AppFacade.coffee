

module.exports = (Module) ->
  {
    PointerT
    FuncG, MaybeG
    FacadeInterface
    Facade
  } = Module.NS

  class AppFacade extends Facade
    @inheritProtected()
    @module Module

    vpbIsInitialized = PointerT @private isInitialized: MaybeG(Boolean),
      default: no
    cphInstanceMap  = PointerT @classVariables['~instanceMap'].pointer

    @public startup: Function,
      default: ->
        unless @[vpbIsInitialized]
          @[vpbIsInitialized] = yes
          @registerCommand Module.NS.STARTUP, Module.NS.StartupCommand
          @sendNotification Module.NS.STARTUP
        return

    @public finish: Function,
      default: ->
        @removeMediator  Module.NS.ConsoleComponentMediator::CONSOLE_MEDIATOR
        return

    @public @static getInstance: FuncG(String, FacadeInterface),
      default: (asKey)->
        vhInstanceMap = Module.NS.Facade[cphInstanceMap]
        unless vhInstanceMap[asKey]?
          vhInstanceMap[asKey] = Module.NS.AppFacade.new asKey
        vhInstanceMap[asKey]

    @initialize()
