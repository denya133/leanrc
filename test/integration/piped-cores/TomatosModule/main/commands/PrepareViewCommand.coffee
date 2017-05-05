

module.exports = (Module) ->
  {
    SimpleCommand
    MainJunctionMediator
  } = Module::

  class PrepareViewCommand extends SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: Function,
      default: (aoNotification)->
        @facade.registerMediator MainJunctionMediator.new()
        return


  PrepareViewCommand.initialize()
