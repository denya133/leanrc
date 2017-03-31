LeanRC = require.main.require 'lib'

module.exports = (RequestApp) ->
  class RequestApp::PrepareViewCommand extends LeanRC::SimpleCommand
    @inheritProtected()
    @Module: RequestApp

    @public execute: Function,
      default: ->
        @facade.registerMediator RequestApp::ConsoleComponentMediator.new RequestApp::ConsoleComponentMediator.CONSOLE_MEDIATOR

  RequestApp::PrepareViewCommand.initialize()
