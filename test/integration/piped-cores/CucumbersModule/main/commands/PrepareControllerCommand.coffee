

module.exports = (Module) ->
  {
    DELAYED_JOBS_SCRIPT

    SimpleCommand
    DelayedJobScript
    CucumbersStock
  } = Module::

  class PrepareControllerCommand extends SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: Function,
      default: ->
        @facade.registerCommand DELAYED_JOBS_SCRIPT, DelayedJobScript
        @facade.registerCommand 'CucumbersStock', CucumbersStock


  PrepareControllerCommand.initialize()
