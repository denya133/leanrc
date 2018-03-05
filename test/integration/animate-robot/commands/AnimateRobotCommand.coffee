

module.exports = (Module) ->
  class AnimateRobotCommand extends Module.NS.SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: Function,
      default: ->
        proxy = @facade.retrieveProxy Module.NS.RobotDataProxy::ROBOT_PROXY
        proxy.animate()

  AnimateRobotCommand.initialize()
