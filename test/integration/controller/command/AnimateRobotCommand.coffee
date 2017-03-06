LeanRC = require.main.require 'lib'

module.exports = (TestApp) ->
  class TestApp::AnimateRobotCommand extends LeanRC::SimpleCommand
    @inheritProtected()
    @Module: TestApp

    ipmFacade = @protected facade: LeanRC::FacadeInterface

    @public execute: Function,
      default: ->
        console.log 'Animate robot to say "Hallo World"'

  TestApp::AnimateRobotCommand.initialize()
