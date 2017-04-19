

module.exports = (Module) ->
  class PrepareModelCommand extends Module::SimpleCommand
    @inheritProtected()
    @Module: Module

    @public execute: Function,
      default: ->
        @facade.registerProxy Module::RobotDataProxy.new Module::RobotDataProxy::ROBOT_PROXY, no

  PrepareModelCommand.initialize()
