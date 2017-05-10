

module.exports = (Module) ->
  {
    STARTUP
    DELAYED_JOBS_SCRIPT
    CONFIGURATION
    RESQUE
    APPLICATION_RENDERER
    APPLICATION_ROUTER

    Facade
    StartupCommand
  } = Module::

  class ApplicationFacade extends Facade
    @inheritProtected()
    @module Module

    vpbIsInitialized = @private isInitialized: Boolean,
      default: no
    cphInstanceMap  = @protected @static instanceMap: Object,
      default: {}

    @protected initializeController: Function,
      default: (args...)->
        @super args...
        @registerCommand STARTUP, StartupCommand
        # ... здесь могут быть регистрации и других команд

    @public startup: Function,
      default: (aoApplication)->
        unless @[vpbIsInitialized]
          @[vpbIsInitialized] = yes
          @sendNotification STARTUP, aoApplication

    @public finish: Function,
      default: ->
        @removeCommand STARTUP
        @removeCommand DELAYED_JOBS_SCRIPT
        @removeCommand 'CucumbersStock'

        @removeProxy CONFIGURATION
        @removeProxy RESQUE
        @removeProxy APPLICATION_RENDERER
        @removeProxy APPLICATION_ROUTER
        @removeProxy 'CucumbersCollection'

        @removeMediator 'CucumbersMainJunctionMediator'

    @public @static getInstance: Function,
      default: (asKey)->
        vhInstanceMap = Facade[cphInstanceMap]
        unless vhInstanceMap[asKey]?
          vhInstanceMap[asKey] = ApplicationFacade.new asKey
        vhInstanceMap[asKey]


  ApplicationFacade.initialize()
