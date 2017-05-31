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
        response = Response.new context
        assert.instanceOf response, Response
        yield return
  describe '#ctx', ->
    it 'should get context object', ->
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
        response = Response.new context
        assert.equal response.ctx, context
        yield return
  describe '#res', ->
    it 'should get native resource object', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Response extends LeanRC::Response
          @inheritProtected()
          @module Test
        Response.initialize()
        res = {}
        context = { res }
        response = Response.new context
        assert.equal response.res, res
        yield return
  describe '#switch', ->
    it 'should get switch object', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Response extends LeanRC::Response
          @inheritProtected()
          @module Test
        Response.initialize()
        switchObject = {}
        context = switch: switchObject
        response = Response.new context
        assert.equal response.switch, switchObject
        yield return
  describe '#socket', ->
    it 'should get socket object', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Response extends LeanRC::Response
          @inheritProtected()
          @module Test
        Response.initialize()
        socket = {}
        context = req: { socket }
        response = Response.new context
        assert.equal response.socket, socket
        yield return
  describe '#headerSent', ->
    it 'should get res.headersSent value', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Response extends LeanRC::Response
          @inheritProtected()
          @module Test
        Response.initialize()
        res = headersSent: yes
        context = { res }
        response = Response.new context
        assert.equal response.headerSent, res.headersSent
        yield return
