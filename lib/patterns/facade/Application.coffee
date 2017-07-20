

module.exports = (Module)->
  {
    LIGHTWEIGHT
    APPLICATION_MEDIATOR

    Pipes
    ConfigurableMixin
    ApplicationInterface
    ContextInterface
    Utils: {uuid}
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

    @public isLightweight: Boolean
    @public context: ContextInterface

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

    @public @async execute: Function,
      default: (resourceName, {context, reverse}, action)->
        @context = context
        appMediator = @facade.retrieveMediator APPLICATION_MEDIATOR
        return yield appMediator.execute resourceName, {context, reverse}, action

    @public init: Function,
      default: (symbol)->
        {ApplicationFacade} = @constructor.Module::
        isLightweight = symbol is LIGHTWEIGHT
        {NAME, name} = @constructor
        if isLightweight
          @super ApplicationFacade.getInstance "#{NAME ? name}|>#{uuid.v4()}"
        else
          @super ApplicationFacade.getInstance NAME ? name
        @isLightweight = isLightweight
        @facade.startup @
        return


  Application.initialize()
