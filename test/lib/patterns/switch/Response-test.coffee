{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
accepts = require 'accepts'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils


describe 'Response', ->
  describe '.new', ->
    it 'should create Response instance', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Response extends LeanRC::Response
          @inheritProtected()
          @module Test
        Response.initialize()
        context = {}
        request = Response.new context
        assert.instanceOf request, Response
        yield return
