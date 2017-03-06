LeanRC = require.main.require 'lib'

module.exports = (TestApp) ->
  class TestApp::AnimateRobotCommand extends LeanRC::SimpleCommand
    @inheritProtected()
    @Module: TestApp

    @public execute: Function,
      default: ->
        proxy = @[Symbol.for 'facade'].retrieveProxy TestApp::RobotDataProxy.ROBOT_PROXY
        proxy.animate()

  TestApp::AnimateRobotCommand.initialize()
