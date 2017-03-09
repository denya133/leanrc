LeanRC = require.main.require 'lib'

module.exports = (RequestApp) ->
  class RequestApp::StartupCommand extends LeanRC::MacroCommand
    @inheritProtected()
    @Module: RequestApp

    @public initializeMacroCommand: Function,
      default: ->
        @addSubCommand RequestApp::PrepareControllerCommand
        @addSubCommand RequestApp::PrepareViewCommand
        @addSubCommand RequestApp::PrepareModelCommand

  RequestApp::StartupCommand.initialize()
