

module.exports = (Module) ->
  {
    MIGRATE
    ROLLBACK

    SimpleCommand
    MigrateCommand
    RollbackCommand
  } = Module::

  class PrepareControllerCommand extends SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: Function,
      default: ->
        @facade.registerCommand MIGRATE, MigrateCommand
        @facade.registerCommand ROLLBACK, RollbackCommand


  PrepareControllerCommand.initialize()
