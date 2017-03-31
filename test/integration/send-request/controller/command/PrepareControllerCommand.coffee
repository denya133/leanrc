LeanRC = require.main.require 'lib'

module.exports = (RequestApp) ->
  class RequestApp::PrepareControllerCommand extends LeanRC::SimpleCommand
    @inheritProtected()
    @Module: RequestApp

    @public execute: Function,
      default: ->
        @facade.registerCommand RequestApp::AppConstants.SEND_REQUEST,
          RequestApp::SendRequestCommand

  RequestApp::PrepareControllerCommand.initialize()
