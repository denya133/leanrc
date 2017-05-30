{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
NodeCookies = require 'cookies'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils


describe 'Cookies', ->
  describe '.new', ->
    it 'should create Cookies instance', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Cookies extends LeanRC::Cookies
          @inheritProtected()
          @module Test
        Cookies.initialize()
        request = {}
        response = {}
        options =
          key: 'KEY'
          secure: 'SECURE'
        cookies = Cookies.new request, response, options
        assert.instanceOf cookies, Cookies
        assert.equal cookies.request, request
        assert.equal cookies.response, response
        assert.equal cookies.key, 'KEY'
        assert.instanceOf cookies[Symbol.for '~cookies'], NodeCookies
        yield return
