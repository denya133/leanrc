LeanRC = require.main.require 'lib'

module.exports = (TestApp) ->
  class TestApp::PrepareViewCommand extends LeanRC::SimpleCommand
    @inheritProtected()
    @Module: TestApp

    @public execute: Function,
      default: ->
        @facade.registerMediator TestApp::ConsoleComponentMediator.new TestApp::ConsoleComponentMediator.CONSOLE_MEDIATOR

  TestApp::PrepareViewCommand.initialize()
