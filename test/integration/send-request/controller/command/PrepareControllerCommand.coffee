

module.exports = (Module) ->
  class PrepareControllerCommand extends Module::SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: Function,
      default: ->
        @facade.registerCommand Module::SEND_REQUEST,
          Module::SendRequestCommand

  PrepareControllerCommand.initialize()
