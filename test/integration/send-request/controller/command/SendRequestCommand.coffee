LeanRC = require.main.require 'lib'

module.exports = (RequestApp) ->
  class RequestApp::SendRequestCommand extends LeanRC::SimpleCommand
    @inheritProtected()
    @Module: RequestApp

    @public execute: Function,
      default: ->
        proxy = @[Symbol.for 'facade'].retrieveProxy RequestApp::RequestProxy.REQUEST_PROXY
        proxy.animate()

  RequestApp::SendRequestCommand.initialize()
