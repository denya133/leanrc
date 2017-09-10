http = require 'http'
EventEmitter = require 'events'
{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
NodeCookies = require 'cookies'
Keygrip = require 'keygrip'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils

trigger = new EventEmitter
server = http.createServer (req, res) -> trigger.emit 'REQUEST', { req, res }


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
  describe '#set', ->
    before ->
      server.listen 8888
    after ->
      server.close()
    it 'should set to cookie value', ->
      co ->
        COOKIE_KEY = 'KEY'
        COOKIE_NAME = 'TEST_COOKIE'
        COOKIE_VALUE = 'TEST_COOKIE_VALUE'
        MAX_AGE = 100000
        DOMAIN = 'example.com'
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Cookies extends LeanRC::Cookies
          @inheritProtected()
          @module Test
        Cookies.initialize()
        promise = LeanRC::Promise.new (resolve) -> trigger.once 'REQUEST', resolve
        LeanRC::Utils.request.get 'http://localhost:8888/'
        { res: response, req: request } = yield promise
        options = key: COOKIE_KEY
        cookies = Cookies.new request, response, options
        startDate = Date.now()
        cookies.set COOKIE_NAME, COOKIE_VALUE,
          maxAge: MAX_AGE
          httpOnly: yes
          path: '/'
          domain: DOMAIN
          secure: no
        cookieHeader = response.getHeader 'Set-Cookie'
        expires = new Date startDate + MAX_AGE
        keys = new Keygrip [ COOKIE_KEY ], 'sha256', 'hex'
        assert.deepEqual cookieHeader, [
          "#{COOKIE_NAME}=#{COOKIE_VALUE}; path=/; expires=#{expires.toUTCString()}; domain=#{DOMAIN}; httponly"
          "#{COOKIE_NAME}.sig=#{keys.sign "#{COOKIE_NAME}=#{COOKIE_VALUE}"}; path=/; expires=#{expires.toUTCString()}; domain=#{DOMAIN}; httponly"
        ]
        yield return
  describe '#get', ->
    before ->
      server.listen 8888
    after ->
      server.close()
    it 'should set to cookie value', ->
      co ->
        COOKIE_KEY = 'KEY'
        COOKIE_NAME = 'TEST_COOKIE'
        COOKIE_VALUE = 'TEST_COOKIE_VALUE'
        MAX_AGE = 100000
        DOMAIN = 'example.com'
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Cookies extends LeanRC::Cookies
          @inheritProtected()
          @module Test
        Cookies.initialize()
        promise = LeanRC::Promise.new (resolve) -> trigger.once 'REQUEST', resolve
        keys = new Keygrip [ COOKIE_KEY ], 'sha256', 'hex'
        LeanRC::Utils.request.get 'http://localhost:8888/',
          headers:
            'Cookie': "#{COOKIE_NAME}=#{COOKIE_VALUE}; #{COOKIE_NAME}.sig=#{keys.sign "#{COOKIE_NAME}=#{COOKIE_VALUE}"}"
        { res: response, req: request } = yield promise
        options = key: COOKIE_KEY
        cookies = Cookies.new request, response, options
        cookieValue = cookies.get COOKIE_NAME
        assert.equal cookieValue, COOKIE_VALUE
        encriptedCookieValue = cookies.get "#{COOKIE_NAME}.sig"
        assert.equal encriptedCookieValue, keys.sign "#{COOKIE_NAME}=#{COOKIE_VALUE}"
        yield return
