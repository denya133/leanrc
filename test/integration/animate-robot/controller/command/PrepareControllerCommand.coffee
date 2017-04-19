

module.exports = (Module) ->
  class PrepareControllerCommand extends Module::SimpleCommand
    @inheritProtected()
    @Module: Module

    @public execute: Function,
      default: ->
        @facade.registerCommand Module::ANIMATE_ROBOT,
          Module::AnimateRobotCommand

  PrepareControllerCommand.initialize()
