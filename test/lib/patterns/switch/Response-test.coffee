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
  describe '#headers', ->
    it 'should get response headers', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Response extends LeanRC::Response
          @inheritProtected()
          @module Test
        Response.initialize()
        res =
          _headers: 'Foo': 'Bar'
          getHeaders: -> LeanRC::Utils.copy @_headers
        context = { res }
        response = Response.new context
        assert.deepEqual response.headers, 'Foo': 'Bar'
        yield return
  describe '#header', ->
    it 'should get response headers', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Response extends LeanRC::Response
          @inheritProtected()
          @module Test
        Response.initialize()
        res =
          _headers: 'Foo': 'Bar'
          getHeaders: -> LeanRC::Utils.copy @_headers
        context = { res }
        response = Response.new context
        assert.deepEqual response.header, 'Foo': 'Bar'
        yield return
  describe '#status', ->
    it 'should get and set response status', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Response extends LeanRC::Response
          @inheritProtected()
          @module Test
        Response.initialize()
        res =
          statusCode: 200
          statusMessage: 'OK'
        context = { res }
        response = Response.new context
        assert.equal response.status, 200
        response.status = 400
        assert.equal response.status, 400
        assert.equal res.statusCode, 400
        assert.throws -> response.status = 'TEST'
        assert.throws -> response.status = 0
        assert.doesNotThrow -> response.status = 200
        res.headersSent = yes
        assert.throws -> response.status = 200
        yield return
  describe '#message', ->
    it 'should get and set response message', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Response extends LeanRC::Response
          @inheritProtected()
          @module Test
        Response.initialize()
        res =
          statusCode: 200
          statusMessage: 'OK'
        context = { res }
        response = Response.new context
        assert.equal response.message, 'OK'
        response.message = 'TEST'
        assert.equal response.message, 'TEST'
        assert.equal res.statusMessage, 'TEST'
        yield return
  describe '#get', ->
    it 'should get specified response header', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Response extends LeanRC::Response
          @inheritProtected()
          @module Test
        Response.initialize()
        res =
          _headers: 'foo': 'Bar'
          getHeaders: -> LeanRC::Utils.copy @_headers
        context = { res }
        response = Response.new context
        assert.deepEqual response.get('Foo'), 'Bar'
        yield return
  describe '#set', ->
    it 'should set specified response header', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Response extends LeanRC::Response
          @inheritProtected()
          @module Test
        Response.initialize()
        res =
          _headers: 'foo': 'Bar'
          getHeaders: -> LeanRC::Utils.copy @_headers
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
        context = { res }
        response = Response.new context
        response.set 'Content-Type', 'text/plain'
        assert.equal res._headers['content-type'], 'text/plain'
        assert.equal response.get('Content-Type'), 'text/plain'
        now = new Date
        response.set 'Date', now
        assert.equal response.get('Date'), "#{now}"
        array = [ 1, now, 'TEST']
        response.set 'Test', array
        assert.deepEqual response.get('Test'), [ '1', "#{now}", 'TEST']
        response.set
          'Abc': 123
          'Last-Date': now
          'New-Test': 'Test'
        assert.equal response.get('Abc'), '123'
        assert.equal response.get('Last-Date'), "#{now}"
        assert.equal response.get('New-Test'), 'Test'
        yield return
  describe '#append', ->
    it 'should add specified response header value', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Response extends LeanRC::Response
          @inheritProtected()
          @module Test
        Response.initialize()
        res =
          _headers: 'foo': 'Bar'
          getHeaders: -> LeanRC::Utils.copy @_headers
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
        context = { res }
        response = Response.new context
        response.append 'Test', 'data'
        assert.equal response.get('Test'), 'data'
        response.append 'Test', 'Test'
        assert.deepEqual response.get('Test'), [ 'data', 'Test' ]
        response.append 'Test', 'Test'
        assert.deepEqual response.get('Test'), [ 'data', 'Test', 'Test' ]
        yield return
