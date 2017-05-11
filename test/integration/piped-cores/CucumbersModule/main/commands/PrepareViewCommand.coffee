

module.exports = (Module) ->
  {
    SimpleCommand
    MainJunctionMediator
    MainSwitch
  } = Module::

  class PrepareViewCommand extends SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: Function,
      default: (aoNotification)->
        @facade.registerMediator MainJunctionMediator.new()
        @facade.registerMediator MainSwitch.new()
        return


  PrepareViewCommand.initialize()
