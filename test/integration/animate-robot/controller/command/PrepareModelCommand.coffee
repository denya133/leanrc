LeanRC = require.main.require 'lib'

module.exports = (TestApp) ->
  class TestApp::PrepareModelCommand extends LeanRC::SimpleCommand
    @inheritProtected()
    @Module: TestApp

    @public execute: Function,
      default: ->
        @facade.registerProxy TestApp::RobotDataProxy.new TestApp::RobotDataProxy.ROBOT_PROXY, no

  TestApp::PrepareModelCommand.initialize()
