

module.exports = (Module)->
  {
    LIGHTWEIGHT
    APPLICATION_MEDIATOR
    AnyT
    FuncG, MaybeG, StructG
    ApplicationInterface, ContextInterface, ResourceInterface
    Pipes
    ConfigurableMixin
    Utils: {uuid}
  } = Module::
  {
    PipeAwareModule
  } = Pipes::

  class Application extends PipeAwareModule
    @inheritProtected()
    @include ConfigurableMixin
    @implements ApplicationInterface
    @module Module

    @const LOGGER_PROXY: 'LoggerProxy'
    @const CONNECT_MODULE_TO_LOGGER: 'connectModuleToLogger'
    @const CONNECT_SHELL_TO_LOGGER: 'connectShellToLogger'
    @const CONNECT_MODULE_TO_SHELL: 'connectModuleToShell'

    @public isLightweight: Boolean
    @public context: MaybeG ContextInterface

    @public @static NAME: String,
      get: -> @Module.name

    @public finish: Function,
      default: ->
        @facade.remove()
        # @facade = undefined
        return

    @public @async migrate: FuncG([MaybeG StructG until: MaybeG String]),
      default: (opts)->
        appMediator = @facade.retrieveMediator APPLICATION_MEDIATOR
        return yield appMediator.migrate opts

    @public @async rollback: FuncG([MaybeG StructG steps: MaybeG(Number), until: MaybeG String]),
      default: (opts)->
        appMediator = @facade.retrieveMediator APPLICATION_MEDIATOR
        return yield appMediator.rollback opts

    @public @async run: FuncG([String, MaybeG AnyT], MaybeG AnyT),
      default: (scriptName, data)->
        appMediator = @facade.retrieveMediator APPLICATION_MEDIATOR
        return yield appMediator.run scriptName, data

    @public @async execute: FuncG([String, StructG({
      context: ContextInterface, reverse: String
    }), String], StructG {
      result: MaybeG(AnyT), resource: ResourceInterface
    }),
      default: (resourceName, {context, reverse}, action)->
        @context = context
        appMediator = @facade.retrieveMediator APPLICATION_MEDIATOR
        return yield appMediator.execute resourceName, {context, reverse}, action

    @public init: FuncG([MaybeG Symbol]),
      default: (symbol)->
        {ApplicationFacade} = @constructor.Module.NS ? @constructor.Module::
        isLightweight = symbol is LIGHTWEIGHT
        {NAME, name} = @constructor
        if isLightweight
          @super ApplicationFacade.getInstance "#{NAME ? name}|>#{uuid.v4()}"
        else
          @super ApplicationFacade.getInstance NAME ? name
        @isLightweight = isLightweight
        @facade.startup @
        return


    @initialize()
