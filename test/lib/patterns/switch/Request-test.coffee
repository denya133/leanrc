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
  describe '#headers', ->
    it 'should get headers value', ->
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
        assert.equal request.headers, context.req.headers
        yield return
  describe '#header', ->
    it 'should get header value', ->
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
        assert.equal request.header, context.req.headers
        yield return
  describe '#originalUrl', ->
    it 'should get original URL', ->
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
          originalUrl: 'http://localhost:8888'
          switch:
            configs:
              trustProxy: yes
          req:
            headers: 'x-forwarded-for': '192.168.0.1'
        request = Request.new context
        assert.equal request.originalUrl, context.originalUrl
        yield return
  describe '#url', ->
    it 'should set and get native request URL', ->
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
            url: 'http://localhost:8888'
            headers: 'x-forwarded-for': '192.168.0.1'
        request = Request.new context
        assert.equal request.url, 'http://localhost:8888'
        request.url = 'http://localhost:9999'
        assert.equal request.url, 'http://localhost:9999'
        assert.equal context.req.url, 'http://localhost:9999'
        yield return
  describe '#socket', ->
    it 'should get request socket', ->
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
            url: 'http://localhost:8888'
            headers: 'x-forwarded-for': '192.168.0.1'
            socket: {}
        request = Request.new context
        assert.equal request.socket, context.req.socket
        yield return
  describe '#protocol', ->
    it 'should get request protocol name', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Request extends LeanRC::Request
          @inheritProtected()
          @module Test
        Request.initialize()
        request = Request.new
          switch: configs: trustProxy: no
          req:
            url: 'http://localhost:8888'
            headers: 'x-forwarded-for': '192.168.0.1'
        assert.equal request.protocol, 'http'
        request = Request.new
          switch: configs: trustProxy: yes
          req:
            url: 'http://localhost:8888'
            headers: 'x-forwarded-for': '192.168.0.1'
        assert.equal request.protocol, 'http'
        request = Request.new
          switch: configs: trustProxy: yes
          req:
            url: 'http://localhost:8888'
            headers: 'x-forwarded-for': '192.168.0.1'
            socket: encrypted: yes
        assert.equal request.protocol, 'https'
        request = Request.new
          switch: configs: trustProxy: yes
          req:
            url: 'http://localhost:8888'
            headers: 'x-forwarded-for': '192.168.0.1'
            secure: yes
        assert.equal request.protocol, 'https'
        request = Request.new
          switch: configs: trustProxy: yes
          req:
            url: 'http://localhost:8888'
            headers:
              'x-forwarded-for': '192.168.0.1'
              'x-forwarded-proto': 'https'
        assert.equal request.protocol, 'https'
        yield return
  describe '#get', ->
    it 'should get single header', ->
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
          switch: configs: trustProxy: yes
          req:
            url: 'http://localhost:8888'
            headers:
              'referrer': 'localhost'
              'x-forwarded-for': '192.168.0.1'
              'x-forwarded-proto': 'https'
              'abc': 'def'
        request = Request.new context
        assert.equal request.get('Referrer'), 'localhost'
        assert.equal request.get('X-Forwarded-For'), '192.168.0.1'
        assert.equal request.get('X-Forwarded-Proto'), 'https'
        assert.equal request.get('Abc'), 'def'
        assert.equal request.get('123'), ''
        yield return
