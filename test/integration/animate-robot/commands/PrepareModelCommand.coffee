

module.exports = (Module) ->
  class PrepareModelCommand extends Module.NS.SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: Function,
      default: ->
        @facade.registerProxy Module.NS.RobotDataProxy.new Module.NS.RobotDataProxy::ROBOT_PROXY, no

  PrepareModelCommand.initialize()
