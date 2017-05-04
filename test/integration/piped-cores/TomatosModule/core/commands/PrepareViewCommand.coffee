

module.exports = (Module) ->
  {
    SimpleCommand
    CoreJunctionMediator
  } = Module::

  class PrepareViewCommand extends SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: Function,
      default: (aoNotification)->
        @facade.registerMediator CoreJunctionMediator.new()
        return


  PrepareViewCommand.initialize()
