

module.exports = (Module)->
  {
    FuncG, MaybeG
    PipeAwareInterface, PipeFittingInterface
    FacadeInterface
    CoreObject
  } = Module::
  {
    ACCEPT_INPUT_PIPE
    ACCEPT_OUTPUT_PIPE
  } = Module::JunctionMediator

  class PipeAwareModule extends CoreObject
    @inheritProtected()
    @implements PipeAwareInterface
    @module Module

    @public @static STDOUT: String,
      default: 'standardOutput'
    @public @static STDIN: String,
      default: 'standardInput'
    @public @static STDLOG: String,
      default: 'standardLog'
    @public @static STDSHELL: String,
      default: 'standardShell'

    @public facade: FacadeInterface

    @public acceptInputPipe: FuncG([String, PipeFittingInterface]),
      default: (asName, aoPipe)->
        @facade.sendNotification ACCEPT_INPUT_PIPE, aoPipe, asName
        return

    @public acceptOutputPipe: FuncG([String, PipeFittingInterface]),
      default: (asName, aoPipe)->
        @facade.sendNotification ACCEPT_OUTPUT_PIPE, aoPipe, asName
        return

    @public @static @async restoreObject: Function,
      default: ->
        throw new Error "restoreObject method not supported for #{@name}"
        yield return

    @public @static @async replicateObject: Function,
      default: ->
        throw new Error "replicateObject method not supported for #{@name}"
        yield return

    @public init: FuncG(MaybeG FacadeInterface),
      default: (aoFacade)->
        @super arguments...
        @facade = aoFacade if aoFacade?
        return


    @initialize()
