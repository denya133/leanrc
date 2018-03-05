

module.exports = (Module) ->
  class PrepareControllerCommand extends Module.NS.SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: Function,
      default: ->
        @facade.registerCommand Module.NS.SEND_REQUEST,
          Module.NS.SendRequestCommand

  PrepareControllerCommand.initialize()
