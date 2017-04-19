

module.exports = (Module) ->
  class AnimateRobotCommand extends Module::SimpleCommand
    @inheritProtected()
    @Module: Module

    @public execute: Function,
      default: ->
        proxy = @facade.retrieveProxy Module::RobotDataProxy::ROBOT_PROXY
        proxy.animate()

  AnimateRobotCommand.initialize()
