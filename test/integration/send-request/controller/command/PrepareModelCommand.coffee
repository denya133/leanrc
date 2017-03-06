LeanRC = require.main.require 'lib'

module.exports = (RequestApp) ->
  class RequestApp::PrepareModelCommand extends LeanRC::SimpleCommand
    @inheritProtected()
    @Module: RequestApp

    @public execute: Function,
      default: ->
        @[Symbol.for 'facade'].registerProxy RequestApp::RequestProxy.new RequestApp::RequestProxy.REQUEST_PROXY, no

  RequestApp::PrepareModelCommand.initialize()
