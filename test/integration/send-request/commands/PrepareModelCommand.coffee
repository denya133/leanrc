

module.exports = (Module) ->
  {
    NilT
    FuncG
    NotificationInterface
    RequestProxy
    SimpleCommand
  } = Module.NS

  class PrepareModelCommand extends SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: FuncG(NotificationInterface, NilT),
      default: ->
        @facade.registerProxy RequestProxy.new RequestProxy::REQUEST_PROXY, no

    @initialize()
