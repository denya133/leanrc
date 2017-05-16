

module.exports = (Module) ->
  {
    DELAYED_JOBS_SCRIPT

    SimpleCommand
    DelayedJobScript
    TomatosResource
  } = Module::

  class PrepareControllerCommand extends SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: Function,
      default: ->
        @facade.registerCommand DELAYED_JOBS_SCRIPT, DelayedJobScript
        @facade.registerCommand 'TomatosResource', TomatosResource


  PrepareControllerCommand.initialize()
