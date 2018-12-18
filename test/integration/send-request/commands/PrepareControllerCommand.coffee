

module.exports = (Module) ->
  {
    NilT
    FuncG
    NotificationInterface
    SEND_REQUEST
    SendRequestCommand
    SimpleCommand
  } = Module.NS

  class PrepareControllerCommand extends SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: FuncG(NotificationInterface, NilT),
      default: ->
        @facade.registerCommand SEND_REQUEST, SendRequestCommand

    @initialize()
