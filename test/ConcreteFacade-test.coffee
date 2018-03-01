{ expect, assert } = require 'chai'
sinon = require 'sinon'
request = require 'request'
LeanRC = require.main.require 'lib'
TestApp = require './integration/animate-robot'
AppFacade = TestApp.NS.AppFacade
RequestApp = require './integration/send-request'
RequestFacade = RequestApp::AppFacade

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
        consoleComponent = TestApp.NS.ConsoleComponent.getInstance()
        consoleComponentSpy = sinon.spy consoleComponent, 'writeMessages'
        consoleComponent.startAnimateRobot()
        assert consoleComponentSpy.called
        app.finish()
      .to.not.throw Error
  describe 'Create RequestApp::AppFacade', ->
    before ->
      sinon
        .stub request, 'get'
        .callsArgWithAsync 1, null, null, JSON.stringify
          message: 'I am awaken. Hello World'
    after ->
      request.get.restore()
    it 'should get instance of Facade and make request', (done) ->
      expect ->
        app = RequestFacade.getInstance 'HELLO_WORLD3'
        app.startup()
        consoleComponent = RequestApp::ConsoleComponent.getInstance()
        consoleComponentSpy = sinon.spy consoleComponent, 'writeMessages'
        consoleComponent.subscribeEventOnce RequestApp::ConsoleComponent::MESSAGE_WRITTEN, =>
          assert consoleComponentSpy.called, 'Console not filled'
          app.finish()
          done()
        consoleComponent.sendRequest()
      .to.not.throw Error
