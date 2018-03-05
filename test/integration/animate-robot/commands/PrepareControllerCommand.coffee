

module.exports = (Module) ->
  class PrepareControllerCommand extends Module.NS.SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: Function,
      default: ->
        @facade.registerCommand Module.NS.ANIMATE_ROBOT,
          Module.NS.AnimateRobotCommand

  PrepareControllerCommand.initialize()
