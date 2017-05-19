

module.exports = (Module) ->
  {
    DELAYED_JOBS_SCRIPT

    SimpleCommand
    DelayedJobScript
    CucumbersResource
    TestScript
  } = Module::

  class PrepareControllerCommand extends SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: Function,
      default: ->
        @facade.registerCommand DELAYED_JOBS_SCRIPT, DelayedJobScript
        @facade.registerCommand 'CucumbersResource', CucumbersResource
        @facade.registerCommand 'TestScript', TestScript


  PrepareControllerCommand.initialize()
