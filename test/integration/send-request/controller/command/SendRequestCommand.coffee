

module.exports = (Module) ->
  class SendRequestCommand extends Module::SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: Function,
      default: ->
        proxy = @facade.retrieveProxy Module::RequestProxy::REQUEST_PROXY
        proxy.request {}

  SendRequestCommand.initialize()
