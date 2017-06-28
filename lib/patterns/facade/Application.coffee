

module.exports = (Module)->
  {
    MIGRATOR
    APPLICATION_MEDIATOR

    Pipes
    ConfigurableMixin
    ApplicationInterface
  } = Module::
  {
    PipeAwareModule
  } = Pipes::

  class Application extends PipeAwareModule
    @inheritProtected()
    @implements ApplicationInterface
    @include ConfigurableMixin
    @module Module

    @const LOGGER_PROXY: Symbol 'LoggerProxy'
    @const CONNECT_MODULE_TO_LOGGER: Symbol 'connectModuleToLogger'
    @const CONNECT_SHELL_TO_LOGGER: Symbol 'connectShellToLogger'
    @const CONNECT_MODULE_TO_SHELL: Symbol 'connectModuleToShell'

    @public isMigrator: Boolean

    @public @static NAME: String,
      get: -> @Module.name

    @public finish: Function,
      default: ->
        @facade.remove()
        @facade = undefined
        return

    @public @async migrate: Function,
      default: (opts)->
        appMediator = @facade.retrieveMediator APPLICATION_MEDIATOR
        return yield appMediator.migrate opts

    @public @async rollback: Function,
      default: (opts)->
        appMediator = @facade.retrieveMediator APPLICATION_MEDIATOR
        return yield appMediator.rollback opts

    @public @async run: Function,
      default: (scriptName, data)->
        appMediator = @facade.retrieveMediator APPLICATION_MEDIATOR
        return yield appMediator.run scriptName, data

    @public init: Function,
      default: (symbol)->
        {ApplicationFacade} = @constructor.Module::
        {NAME, name} = @constructor
        @super ApplicationFacade.getInstance NAME ? name
        @isMigrator = symbol is MIGRATOR
        @facade.startup @
        return


  Application.initialize()
