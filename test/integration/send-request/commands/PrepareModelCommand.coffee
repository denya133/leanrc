

module.exports = (Module) ->
  class PrepareModelCommand extends Module.NS.SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: Function,
      default: ->
        @facade.registerProxy Module.NS.RequestProxy.new Module.NS.RequestProxy::REQUEST_PROXY, no

  PrepareModelCommand.initialize()
