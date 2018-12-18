

module.exports = (Module) ->
  {
    NilT
    FuncG
    NotificationInterface
    RequestProxy
    SimpleCommand
  } = Module.NS

  class SendRequestCommand extends SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: FuncG(NotificationInterface, NilT),
      default: ->
        proxy = @facade.retrieveProxy RequestProxy::REQUEST_PROXY
        proxy.request {}

    @initialize()
