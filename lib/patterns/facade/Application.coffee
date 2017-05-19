

module.exports = (Module)->
  class Application extends Module::Pipes::PipeAwareModule
    @inheritProtected()
    @module Module

    @const LOGGER_PROXY: Symbol 'LoggerProxy'
    @const CONNECT_MODULE_TO_LOGGER: Symbol 'connectModuleToLogger'
    @const CONNECT_SHELL_TO_LOGGER: Symbol 'connectShellToLogger'
    @const CONNECT_MODULE_TO_SHELL: Symbol 'connectModuleToShell'

    @public @static NAME: String,
      get: -> @Module.name

    @public finish: Function,
      default: ->
        @facade.remove()
        @facade = undefined
        return

    @public init: Function,
      default: ->
        {ApplicationFacade} = @constructor.Module::
        {NAME, name} = @constructor
        @super ApplicationFacade.getInstance NAME ? name
        @facade.startup @
        return


  Application.initialize()
