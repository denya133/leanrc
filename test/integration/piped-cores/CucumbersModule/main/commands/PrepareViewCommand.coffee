

module.exports = (Module) ->
  {
    MEM_RESQUE_EXEC

    SimpleCommand
    MainJunctionMediator
    MainSwitch
    MemoryResqueExecutor
  } = Module::

  class PrepareViewCommand extends SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: Function,
      default: (aoNotification)->
        @facade.registerMediator MainJunctionMediator.new()
        @facade.registerMediator MainSwitch.new()
        @facade.registerMediator MemoryResqueExecutor.new MEM_RESQUE_EXEC
        return


  PrepareViewCommand.initialize()
