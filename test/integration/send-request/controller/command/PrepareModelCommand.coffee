

module.exports = (Module) ->
  class PrepareModelCommand extends Module::SimpleCommand
    @inheritProtected()
    @Module: Module

    @public execute: Function,
      default: ->
        @facade.registerProxy Module::RequestProxy.new Module::RequestProxy::REQUEST_PROXY, no

  PrepareModelCommand.initialize()
