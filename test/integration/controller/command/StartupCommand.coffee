LeanRC = require.main.require 'lib'

module.exports = (TestApp) ->
  class TestApp::StartupCommand extends LeanRC::MacroCommand
    @inheritProtected()
    @Module: TestApp

    @public initializeMacroCommand: Function,
      default: ->
        console.log 'Hello World'

  TestApp::StartupCommand.initialize()
