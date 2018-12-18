

module.exports = (Module) ->
  {
    NilT
    FuncG
    NotificationInterface
    RobotDataProxy
    SimpleCommand
  } = Module.NS

  class PrepareModelCommand extends SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: FuncG(NotificationInterface, NilT),
      default: ->
        @facade.registerProxy RobotDataProxy.new RobotDataProxy::ROBOT_PROXY, no

    @initialize()
