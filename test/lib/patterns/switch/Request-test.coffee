{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils


describe 'Request', ->
  describe '.new', ->
    it 'should create Request instance', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Request extends LeanRC::Request
          @inheritProtected()
          @module Test
        Request.initialize()
        context =
          switch:
            configs:
              trustProxy: yes
          req:
            headers: 'x-forwarded-for': '192.168.0.1'
        request = Request.new context
        assert.instanceOf request, Request
        assert.equal request.ctx, context
        assert.equal request.ip, '192.168.0.1'
        yield return
  describe '#req', ->
    it 'should get request native value', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Request extends LeanRC::Request
          @inheritProtected()
          @module Test
        Request.initialize()
        context =
          switch:
            configs:
              trustProxy: yes
          req:
            headers: 'x-forwarded-for': '192.168.0.1'
        request = Request.new context
        assert.equal request.req, context.req
        yield return
  describe '#switch', ->
    it 'should get switch internal value', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Request extends LeanRC::Request
          @inheritProtected()
          @module Test
        Request.initialize()
        context =
          switch:
            configs:
              trustProxy: yes
          req:
            headers: 'x-forwarded-for': '192.168.0.1'
        request = Request.new context
        assert.equal request.switch, context.switch
        yield return
