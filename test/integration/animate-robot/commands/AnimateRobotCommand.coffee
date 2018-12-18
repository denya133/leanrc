

module.exports = (Module) ->
  {
    NilT
    FuncG
    NotificationInterface
    RobotDataProxy
    SimpleCommand
  } = Module.NS

  class AnimateRobotCommand extends SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: FuncG(NotificationInterface, NilT),
      default: ->
        proxy = @facade.retrieveProxy RobotDataProxy::ROBOT_PROXY
        proxy.animate()

    @initialize()
