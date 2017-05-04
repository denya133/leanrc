

module.exports = (Module) ->
  {
    SimpleCommand
    HttpClientJunctionMediator
  } = Module::

  class PrepareViewCommand extends SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: Function,
      default: (aoNotification)->
        @facade.registerMediator HttpClientJunctionMediator.new()
        return


  PrepareViewCommand.initialize()
