LeanRC = require.main.require 'lib'

module.exports = (TestApp) ->
  class TestApp::PrepareViewCommand extends LeanRC::SimpleCommand
    @inheritProtected()
    @Module: TestApp

    ipmFacade = @protected facade: LeanRC::FacadeInterface

    @public execute: Function,
      default: ->
        console.log 'Prepare view for Hello World'

  TestApp::PrepareViewCommand.initialize()
