

module.exports = (Module) ->
  {
    DELAYED_JOBS_SCRIPT
    MIGRATE
    ROLLBACK

    SimpleCommand
    DelayedJobScript
    MigrateCommand
    RollbackCommand
    TomatosResource
    ItselfResource
  } = Module::

  class PrepareControllerCommand extends SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: Function,
      default: ->
        @facade.registerCommand DELAYED_JOBS_SCRIPT, DelayedJobScript
        @facade.registerCommand MIGRATE, MigrateCommand
        @facade.registerCommand ROLLBACK, RollbackCommand
        @facade.registerCommand 'TomatosResource', TomatosResource
        @facade.registerCommand 'ItselfResource', ItselfResource


  PrepareControllerCommand.initialize()
