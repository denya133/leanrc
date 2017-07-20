

module.exports = (Module) ->
  class PrepareModelCommand extends Module::SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: Function,
      default: ->
        @facade.registerProxy Module::RobotDataProxy.new Module::RobotDataProxy::ROBOT_PROXY, no

  PrepareModelCommand.initialize()
