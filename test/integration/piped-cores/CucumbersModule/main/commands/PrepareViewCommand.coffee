

module.exports = (Module) ->
  {
    RESQUE_EXECUTOR

    SimpleCommand
    MainJunctionMediator
    MainSwitch
    ResqueExecutor
  } = Module::

  class PrepareViewCommand extends SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: Function,
      default: (aoNotification)->
        @facade.registerMediator MainJunctionMediator.new()
        @facade.registerMediator MainSwitch.new()
        @facade.registerMediator ResqueExecutor.new RESQUE_EXECUTOR
        return


  PrepareViewCommand.initialize()
