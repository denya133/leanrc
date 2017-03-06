LeanRC = require.main.require 'lib'

module.exports = (TestApp) ->
  class TestApp::PrepareControllerCommand extends LeanRC::SimpleCommand
    @inheritProtected()
    @Module: TestApp

    ipmFacade = @protected facade: LeanRC::FacadeInterface

    @public execute: Function,
      default: ->
        console.log 'Hello World'

  TestApp::PrepareControllerCommand.initialize()
