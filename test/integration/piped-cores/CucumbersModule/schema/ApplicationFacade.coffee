

module.exports = (Module) ->
  {
    STARTUP
    MIGRATE
    ROLLBACK
    CONFIGURATION
    RESQUE
    MIGRATIONS
    APPLICATION_MEDIATOR

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
        @removeCommand MIGRATE
        @removeCommand ROLLBACK

        @removeProxy CONFIGURATION
        @removeProxy RESQUE
        @removeProxy MIGRATIONS
        @removeProxy 'CucumbersCollection'

        @removeMediator APPLICATION_MEDIATOR

    @public @static getInstance: Function,
      default: (asKey)->
        vhInstanceMap = Facade[cphInstanceMap]
        unless vhInstanceMap[asKey]?
          vhInstanceMap[asKey] = ApplicationFacade.new asKey
        vhInstanceMap[asKey]


  ApplicationFacade.initialize()
