

module.exports = (Module) ->
  class AnimateRobotCommand extends Module::SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: Function,
      default: ->
        proxy = @facade.retrieveProxy Module::RobotDataProxy::ROBOT_PROXY
        proxy.animate()

  AnimateRobotCommand.initialize()
