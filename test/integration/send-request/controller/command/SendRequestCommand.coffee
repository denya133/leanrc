LeanRC = require.main.require 'lib'

module.exports = (RequestApp) ->
  class RequestApp::SendRequestCommand extends LeanRC::SimpleCommand
    @inheritProtected()
    @Module: RequestApp

    @public execute: Function,
      default: ->
        proxy = @facade.retrieveProxy RequestApp::RequestProxy.REQUEST_PROXY
        proxy.request {}

  RequestApp::SendRequestCommand.initialize()
