

module.exports = (Module) ->
  {
    NilT
    FuncG
    NotificationInterface
    ANIMATE_ROBOT
    AnimateRobotCommand
    SimpleCommand
  } = Module.NS

  class PrepareControllerCommand extends SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: FuncG(NotificationInterface, NilT),
      default: ->
        @facade.registerCommand ANIMATE_ROBOT, AnimateRobotCommand

    @initialize()
