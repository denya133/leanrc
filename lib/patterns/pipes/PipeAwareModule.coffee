

module.exports = (Module)->
  {
    ACCEPT_INPUT_PIPE
    ACCEPT_OUTPUT_PIPE
  } = Module::JunctionMediator

  class PipeAwareModule extends Module::CoreObject
    @inheritProtected()
    @implements Module::PipeAwareInterface
    @module Module

    @public @static STDOUT: String,
      default: 'standardOutput'
    @public @static STDIN: String,
      default: 'standardInput'
    @public @static STDLOG: String,
      default: 'standardLog'
    @public @static STDSHELL: String,
      default: 'standardShell'

    @public facade: Module::FacadeInterface

    @public acceptInputPipe: Function,
      default: (asName, aoPipe)->
        @facade.sendNotification ACCEPT_INPUT_PIPE, aoPipe, asName
        return

    @public acceptOutputPipe: Function,
      default: (asName, aoPipe)->
        @facade.sendNotification ACCEPT_OUTPUT_PIPE, aoPipe, asName
        return

    @public init: Function,
      default: (aoFacade)->
        @super arguments...
        @facade = aoFacade


  PipeAwareModule.initialize()
