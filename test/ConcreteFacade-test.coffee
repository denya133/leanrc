{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
TestApp = require './integration'
AppFacade = TestApp::AppFacade

describe 'ConcreteFacade', ->
  describe 'Create AppFacade', ->
    it 'should get new or existing instance of Facade', ->
      expect ->
        app = AppFacade.getInstance 'HELLO_WORLD'
      .to.not.throw Error
