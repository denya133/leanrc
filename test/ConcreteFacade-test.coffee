{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
TestApp = require './integration/animate-robot'
AppFacade = TestApp::AppFacade
RequestApp = require './integration/animate-robot'
RequestAppFacade = RequestApp::AppFacade

describe 'ConcreteFacade', ->
  describe 'Create AppFacade', ->
    it 'should get new or existing instance of Facade', ->
      expect ->
        app = AppFacade.getInstance 'HELLO_WORLD1'
        app.startup()
        app.finish()
      .to.not.throw Error
  describe 'Create AppFacade', ->
    it 'should send event into application and get response', ->
      expect ->
        app = AppFacade.getInstance 'HELLO_WORLD2'
        app.startup()
        consoleComponent = TestApp::ConsoleComponent.getInstance()
        consoleComponentSpy = sinon.spy consoleComponent, 'writeMessages'
        consoleComponent.startAnimateRobot()
        assert consoleComponentSpy.called
      .to.not.throw Error
  describe 'Create RequestApp::AppFacade', ->
    it 'should get new or existing instance of Facade', ->
      expect ->
        app = RequestAppFacade.getInstance 'HELLO_WORLD3'
        app.startup()
        app.finish()
      .to.not.throw Error
