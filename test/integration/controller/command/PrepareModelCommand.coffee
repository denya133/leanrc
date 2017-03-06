LeanRC = require.main.require 'lib'

module.exports = (TestApp) ->
  class TestApp::PrepareModelCommand extends LeanRC::SimpleCommand
    @inheritProtected()
    @Module: TestApp

    ipmFacade = @protected facade: LeanRC::FacadeInterface

    @public execute: Function,
      default: ->
        console.log 'Prepare model for Hello World'

  TestApp::PrepareModelCommand.initialize()
