LeanRC = require.main.require 'lib'

module.exports = (TestApp) ->
  class TestApp::StartupCommand extends LeanRC::MacroCommand
    @inheritProtected()
    @Module: TestApp

    @public initializeMacroCommand: Function,
      default: ->
        @addSubCommand TestApp::PrepareControllerCommand
        @addSubCommand TestApp::PrepareViewCommand
        @addSubCommand TestApp::PrepareModelCommand

  TestApp::StartupCommand.initialize()
