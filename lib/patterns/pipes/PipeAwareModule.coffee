RC = require 'RC'

module.exports = (LeanRC)->
  {
    ACCEPT_INPUT_PIPE
    ACCEPT_OUTPUT_PIPE
  } = LeanRC::JunctionMediator

  class LeanRC::PipeAwareModule extends RC::CoreObject
    @inheritProtected()
    @implements LeanRC::PipeAwareInterface

    @Module: LeanRC

    @public @static STDOUT: String,
      default: 'standardOutput'
    @public @static STDIN: String,
      default: 'standardInput'
    @public @static STDLOG: String,
      default: 'standardLog'
    @public @static STDSHELL: String,
      default: 'standardShell'

    @public facade: LeanRC::FacadeInterface

    @public acceptInputPipe: Function,
      default: (asName, aoPipe)->
        @[ipoFacade].sendNotification ACCEPT_INPUT_PIPE, aoPipe, asName
        return

    @public acceptOutputPipe: Function,
      default: (asName, aoPipe)->
        @[ipoFacade].sendNotification ACCEPT_OUTPUT_PIPE, aoPipe, asName
        return

    constructor: (aoFacade)->
      super arguments...
      @facade = aoFacade


  return LeanRC::PipeAwareModule.initialize()
