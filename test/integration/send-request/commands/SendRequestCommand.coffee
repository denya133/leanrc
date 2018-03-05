

module.exports = (Module) ->
  class SendRequestCommand extends Module.NS.SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: Function,
      default: ->
        proxy = @facade.retrieveProxy Module.NS.RequestProxy::REQUEST_PROXY
        proxy.request {}

  SendRequestCommand.initialize()
