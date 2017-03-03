{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'

class TestApp
  TestApp::AppConstants =
    STARTUP: 'startup'
  class TestApp::StartupCommand extends LeanRC::MacroCommand
    @inheritProtected()
    @Module: TestApp
    @public initializeMacroCommand: Function,
      default: ->
        console.log 'Hello World'
  class TestApp::AppFacade extends LeanRC::Facade
    @inheritProtected()
    @Module: TestApp
    vpbIsInitialized = @private isInitialized: Boolean,
      default: no
    @public startup: Function,
      default: ->
        unless @[vpbIsInitialized]
          @[vpbIsInitialized] = yes
          @registerCommand TestApp::AppConstants.STARTUP, TestApp::StartupCommand
          @sendNotification TestApp::AppConstants.STARTUP
  TestApp::AppFacade.initialize()

describe 'ConcreteFacade', ->
  describe 'Create AppFacade', ->
    it 'should get new or existing instance of Facade', ->
      expect ->
        AppFacade = TestApp::AppFacade
        app = AppFacade.getInstance 'HELLO_WORLD'
      .to.not.throw Error
