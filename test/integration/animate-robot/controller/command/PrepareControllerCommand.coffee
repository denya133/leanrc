LeanRC = require.main.require 'lib'

module.exports = (TestApp) ->
  class TestApp::PrepareControllerCommand extends LeanRC::SimpleCommand
    @inheritProtected()
    @Module: TestApp

    @public execute: Function,
      default: ->
        @[Symbol.for 'facade'].registerCommand TestApp::AppConstants.ANIMATE_ROBOT,
          TestApp::AnimateRobotCommand

  TestApp::PrepareControllerCommand.initialize()
