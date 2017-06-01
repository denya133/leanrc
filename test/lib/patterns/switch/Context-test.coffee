{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
# accepts = require 'accepts'
httpErrors = require 'http-errors'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils


describe 'Context', ->
  describe '.new', ->
    it 'should create Context instance', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Context extends LeanRC::Context
          @inheritProtected()
          @module Test
        Context.initialize()
        switchInstance =
          configs:
            trustProxy: yes
            cookieKey: 'COOKIE_KEY'
        req =
          url: 'http://localhost:8888/test1'
          headers: 'x-forwarded-for': '192.168.0.1'
          secure: no
        res =
          _headers: 'Foo': 'Bar'
        context = Context.new req, res, switchInstance
        assert.instanceOf context, Context
        assert.equal context.req, req
        assert.equal context.res, res
        assert.equal context.switch, switchInstance
        assert.instanceOf context.request, Test::Request
        assert.instanceOf context.response, Test::Response
        assert.instanceOf context.cookies, Test::Cookies
        assert.deepEqual context.state, {}
        yield return
  describe '#throw', ->
    it 'should throw an error exception', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Context extends LeanRC::Context
          @inheritProtected()
          @module Test
        Context.initialize()
        switchInstance =
          configs:
            trustProxy: yes
            cookieKey: 'COOKIE_KEY'
        req =
          url: 'http://localhost:8888/test1'
          headers: 'x-forwarded-for': '192.168.0.1'
          secure: no
        res =
          _headers: 'Foo': 'Bar'
        context = Context.new req, res, switchInstance
        assert.throws -> context.throw 404
        , httpErrors.HttpError
        assert.throws -> context.throw 501, 'Not Implemented'
        , httpErrors.HttpError
        yield return
  describe '#assert', ->
    it 'should assert with status codes', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Context extends LeanRC::Context
          @inheritProtected()
          @module Test
        Context.initialize()
        switchInstance =
          configs:
            trustProxy: yes
            cookieKey: 'COOKIE_KEY'
        req =
          url: 'http://localhost:8888/test1'
          headers: 'x-forwarded-for': '192.168.0.1'
          secure: no
        res =
          _headers: 'Foo': 'Bar'
        context = Context.new req, res, switchInstance
        assert.doesNotThrow -> context.assert yes
        assert.throws -> context.assert 'test' is 'TEST', 500, 'Internal Error'
        , Error
        yield return
  describe '#header', ->
    it 'should get request header', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Context extends LeanRC::Context
          @inheritProtected()
          @module Test
        Context.initialize()
        switchInstance =
          configs:
            trustProxy: yes
            cookieKey: 'COOKIE_KEY'
        req =
          url: 'http://localhost:8888/test1'
          headers: 'x-forwarded-for': '192.168.0.1'
          secure: no
        res =
          _headers: 'Foo': 'Bar'
        context = Context.new req, res, switchInstance
        assert.equal context.header, req.headers
        yield return
  describe '#headers', ->
    it 'should get request headers', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Context extends LeanRC::Context
          @inheritProtected()
          @module Test
        Context.initialize()
        switchInstance =
          configs:
            trustProxy: yes
            cookieKey: 'COOKIE_KEY'
        req =
          url: 'http://localhost:8888/test1'
          headers: 'x-forwarded-for': '192.168.0.1'
          secure: no
        res =
          _headers: 'Foo': 'Bar'
        context = Context.new req, res, switchInstance
        assert.equal context.headers, req.headers
        yield return
  describe '#method', ->
    it 'should get and set request method', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Context extends LeanRC::Context
          @inheritProtected()
          @module Test
        Context.initialize()
        switchInstance =
          configs:
            trustProxy: yes
            cookieKey: 'COOKIE_KEY'
        req =
          method: 'POST'
          url: 'http://localhost:8888/test1'
          headers: 'x-forwarded-for': '192.168.0.1'
          secure: no
        res =
          _headers: 'Foo': 'Bar'
        context = Context.new req, res, switchInstance
        assert.equal context.method, 'POST'
        context.method = 'PUT'
        assert.equal context.method, 'PUT'
        assert.equal req.method, 'PUT'
        yield return
  describe '#url', ->
    it 'should get and set request URL', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Context extends LeanRC::Context
          @inheritProtected()
          @module Test
        Context.initialize()
        switchInstance =
          configs:
            trustProxy: yes
            cookieKey: 'COOKIE_KEY'
        req =
          method: 'POST'
          url: 'http://localhost:8888/test1'
          headers: 'x-forwarded-for': '192.168.0.1'
          secure: no
        res =
          _headers: 'Foo': 'Bar'
        context = Context.new req, res, switchInstance
        assert.equal context.url, 'http://localhost:8888/test1'
        context.url = 'http://localhost:8888/test2'
        assert.equal context.url, 'http://localhost:8888/test2'
        assert.equal req.url, 'http://localhost:8888/test2'
        yield return
  describe '#originalUrl', ->
    it 'should get original request URL', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Context extends LeanRC::Context
          @inheritProtected()
          @module Test
        Context.initialize()
        switchInstance =
          configs:
            trustProxy: yes
            cookieKey: 'COOKIE_KEY'
        req =
          method: 'POST'
          url: 'http://localhost:8888/test1'
          headers: 'x-forwarded-for': '192.168.0.1'
          secure: no
        res =
          _headers: 'Foo': 'Bar'
        context = Context.new req, res, switchInstance
        assert.equal context.originalUrl, 'http://localhost:8888/test1'
        yield return
  describe '#origin', ->
    it 'should get request origin data', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Context extends LeanRC::Context
          @inheritProtected()
          @module Test
        Context.initialize()
        switchInstance =
          configs:
            trustProxy: yes
            cookieKey: 'COOKIE_KEY'
        req =
          method: 'POST'
          url: 'http://localhost:8888/test1'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'host': 'localhost:8888'
          secure: no
        res =
          _headers: 'Foo': 'Bar'
        context = Context.new req, res, switchInstance
        assert.equal context.origin, 'http://localhost:8888'
        req.secure = yes
        assert.equal context.origin, 'https://localhost:8888'
        yield return
  describe '#href', ->
    it 'should get request hyper reference', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Context extends LeanRC::Context
          @inheritProtected()
          @module Test
        Context.initialize()
        switchInstance =
          configs:
            trustProxy: yes
            cookieKey: 'COOKIE_KEY'
        req =
          method: 'POST'
          url: '/test1'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'host': 'localhost:8888'
          secure: no
        res =
          _headers: 'Foo': 'Bar'
        context = Context.new req, res, switchInstance
        assert.equal context.href, 'http://localhost:8888/test1'
        req.url = 'http://localhost1:9999/test2'
        context = Context.new req, res, switchInstance
        assert.equal context.href, 'http://localhost1:9999/test2'
        yield return
  describe '#path', ->
    it 'should get and set request path', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Context extends LeanRC::Context
          @inheritProtected()
          @module Test
        Context.initialize()
        switchInstance =
          configs:
            trustProxy: yes
            cookieKey: 'COOKIE_KEY'
        req =
          method: 'POST'
          url: 'http://localhost:8888/test1?t=ttt'
          headers: 'x-forwarded-for': '192.168.0.1'
          secure: no
        res =
          _headers: 'Foo': 'Bar'
        context = Context.new req, res, switchInstance
        assert.equal context.path, '/test1'
        context.path = '/test2'
        assert.equal context.path, '/test2'
        assert.equal req.url, 'http://localhost:8888/test2?t=ttt'
        yield return
  describe '#query', ->
    it 'should get and set request query object', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Context extends LeanRC::Context
          @inheritProtected()
          @module Test
        Context.initialize()
        switchInstance =
          configs:
            trustProxy: yes
            cookieKey: 'COOKIE_KEY'
        req =
          method: 'POST'
          url: 'http://localhost:8888/test1?t=ttt'
          headers: 'x-forwarded-for': '192.168.0.1'
          secure: no
        res =
          _headers: 'Foo': 'Bar'
        context = Context.new req, res, switchInstance
        assert.deepEqual context.query, t: 'ttt'
        context.query = a: 'aaa'
        assert.deepEqual context.query, a: 'aaa'
        assert.equal req.url, 'http://localhost:8888/test1?a=aaa'
        yield return
  describe '#querystring', ->
    it 'should get and set request query string', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Context extends LeanRC::Context
          @inheritProtected()
          @module Test
        Context.initialize()
        switchInstance =
          configs:
            trustProxy: yes
            cookieKey: 'COOKIE_KEY'
        req =
          method: 'POST'
          url: 'http://localhost:8888/test1?t=ttt'
          headers: 'x-forwarded-for': '192.168.0.1'
          secure: no
        res =
          _headers: 'Foo': 'Bar'
        context = Context.new req, res, switchInstance
        assert.equal context.querystring, 't=ttt'
        context.querystring = 'a=aaa'
        assert.equal context.querystring, 'a=aaa'
        assert.equal req.url, 'http://localhost:8888/test1?a=aaa'
        yield return
  describe '#host', ->
    it 'should get request host', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Context extends LeanRC::Context
          @inheritProtected()
          @module Test
        Context.initialize()
        switchInstance =
          configs:
            trustProxy: yes
            cookieKey: 'COOKIE_KEY'
        req =
          headers:
            'x-forwarded-for': '192.168.0.1'
            'host': 'localhost:9999'
        res =
          _headers: 'Foo': 'Bar'
        context = Context.new req, res, switchInstance
        assert.equal context.host, 'localhost:9999'
        req =
          headers:
            'x-forwarded-for': '192.168.0.1'
            'x-forwarded-host': 'localhost:8888, localhost:9999'
        context = Context.new req, res, switchInstance
        assert.equal context.host, 'localhost:8888'
        req =
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Context.new req, res, switchInstance
        assert.equal context.host, ''
        yield return
  describe '#hostname', ->
    it 'should get request host name', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Context extends LeanRC::Context
          @inheritProtected()
          @module Test
        Context.initialize()
        switchInstance =
          configs:
            trustProxy: yes
            cookieKey: 'COOKIE_KEY'
        req =
          headers:
            'x-forwarded-for': '192.168.0.1'
            'host': 'localhost:9999'
        res =
          _headers: 'Foo': 'Bar'
        context = Context.new req, res, switchInstance
        assert.equal context.hostname, 'localhost'
        req =
          headers:
            'x-forwarded-for': '192.168.0.1'
            'x-forwarded-host': 'localhost1:8888, localhost:9999'
        context = Context.new req, res, switchInstance
        assert.equal context.hostname, 'localhost1'
        req =
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Context.new req, res, switchInstance
        assert.equal context.hostname, ''
        yield return
  describe '#fresh', ->
    it 'should test request freshness', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Context extends LeanRC::Context
          @inheritProtected()
          @module Test
        Context.initialize()
        switchInstance =
          configs:
            trustProxy: yes
            cookieKey: 'COOKIE_KEY'
        req =
          method: 'GET'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'if-none-match': '"foo"'
        res =
          _headers: 'etag': '"bar"'
        context = Context.new req, res, switchInstance
        context.status = 200
        assert.isFalse context.fresh
        req =
          method: 'GET'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'if-none-match': '"foo"'
        res =
          _headers: 'etag': '"foo"'
        context = Context.new req, res, switchInstance
        context.status = 200
        assert.isTrue context.fresh
        yield return
  describe '#stale', ->
    it 'should test request non-freshness', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Context extends LeanRC::Context
          @inheritProtected()
          @module Test
        Context.initialize()
        switchInstance =
          configs:
            trustProxy: yes
            cookieKey: 'COOKIE_KEY'
        req =
          method: 'GET'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'if-none-match': '"foo"'
        res =
          _headers: 'etag': '"bar"'
        context = Context.new req, res, switchInstance
        context.status = 200
        assert.isTrue context.stale
        req =
          method: 'GET'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'if-none-match': '"foo"'
        res =
          _headers: 'etag': '"foo"'
        context = Context.new req, res, switchInstance
        context.status = 200
        assert.isFalse context.stale
        yield return
  describe '#socket', ->
    it 'should get request socket', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Context extends LeanRC::Context
          @inheritProtected()
          @module Test
        Context.initialize()
        switchInstance =
          configs:
            trustProxy: yes
            cookieKey: 'COOKIE_KEY'
        req =
          headers:
            'x-forwarded-for': '192.168.0.1'
          socket: {}
        res = _headers: {}
        context = Context.new req, res, switchInstance
        assert.equal context.socket, req.socket
        yield return
  describe '#protocol', ->
    it 'should get request protocol', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Context extends LeanRC::Context
          @inheritProtected()
          @module Test
        Context.initialize()
        switchInstance =
          configs:
            trustProxy: no
            cookieKey: 'COOKIE_KEY'
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        res = _headers: {}
        context = Context.new req, res, switchInstance
        assert.equal context.protocol, 'http'
        switchInstance.configs.trustProxy = yes
        context = Context.new req, res, switchInstance
        assert.equal context.protocol, 'http'
        req.socket = encrypted: yes
        context = Context.new req, res, switchInstance
        assert.equal context.protocol, 'https'
        delete req.socket
        req.secure = yes
        context = Context.new req, res, switchInstance
        assert.equal context.protocol, 'https'
        delete req.secure
        req.headers['x-forwarded-proto'] = 'https'
        context = Context.new req, res, switchInstance
        assert.equal context.protocol, 'https'
        yield return
  describe '#secure', ->
    it 'should check if request secure', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Context extends LeanRC::Context
          @inheritProtected()
          @module Test
        Context.initialize()
        switchInstance =
          configs:
            trustProxy: no
            cookieKey: 'COOKIE_KEY'
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        res = _headers: {}
        context = Context.new req, res, switchInstance
        assert.isFalse context.secure
        switchInstance.configs.trustProxy = yes
        context = Context.new req, res, switchInstance
        assert.isFalse context.secure
        req.socket = encrypted: yes
        context = Context.new req, res, switchInstance
        assert.isTrue context.secure
        delete req.socket
        req.secure = yes
        context = Context.new req, res, switchInstance
        assert.isTrue context.secure
        delete req.secure
        req.headers['x-forwarded-proto'] = 'https'
        context = Context.new req, res, switchInstance
        assert.isTrue context.secure
        yield return
  describe '#ips', ->
    it 'should get request IPs', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Context extends LeanRC::Context
          @inheritProtected()
          @module Test
        Context.initialize()
        switchInstance =
          configs:
            trustProxy: yes
            cookieKey: 'COOKIE_KEY'
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1, 192.168.1.1, 123.222.12.21'
        res = _headers: {}
        context = Context.new req, res, switchInstance
        assert.deepEqual context.ips, [ '192.168.0.1', '192.168.1.1', '123.222.12.21' ]
        yield return
  describe '#ip', ->
    it 'should get request IP', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Context extends LeanRC::Context
          @inheritProtected()
          @module Test
        Context.initialize()
        switchInstance =
          configs:
            trustProxy: yes
            cookieKey: 'COOKIE_KEY'
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1, 192.168.1.1, 123.222.12.21'
        res = _headers: {}
        context = Context.new req, res, switchInstance
        assert.deepEqual context.ip, '192.168.0.1'
        yield return
  describe '#subdomains', ->
    it 'should get request subdomains', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Context extends LeanRC::Context
          @inheritProtected()
          @module Test
        Context.initialize()
        switchInstance =
          configs:
            trustProxy: yes
            cookieKey: 'COOKIE_KEY'
            subdomainOffset: 1
        req =
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'host': 'www.test.localhost:9999'
        res = _headers: {}
        context = Context.new req, res, switchInstance
        assert.deepEqual context.subdomains, [ 'test', 'www' ]
        req.headers.host = '192.168.0.2:9999'
        context = Context.new req, res, switchInstance
        assert.deepEqual context.subdomains, []
        yield return
  describe '#is', ->
    it 'should test types from request', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Context extends LeanRC::Context
          @inheritProtected()
          @module Test
        Context.initialize()
        switchInstance =
          configs:
            trustProxy: yes
            cookieKey: 'COOKIE_KEY'
        req =
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'content-type': 'application/json'
            'content-length': '0'
        res =
          _headers: 'etag': '"bar"'
        context = Context.new req, res, switchInstance
        assert.equal context.is('html' , 'application/*'), 'application/json'
        yield return
  describe '#accepts', ->
    it 'should get acceptable types from request', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Context extends LeanRC::Context
          @inheritProtected()
          @module Test
        Context.initialize()
        switchInstance =
          configs:
            trustProxy: yes
            cookieKey: 'COOKIE_KEY'
        req =
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'accept': 'application/json, text/plain, image/png'
        res = _headers: {}
        context = Context.new req, res, switchInstance
        assert.deepEqual context.accepts(), [
          'application/json', 'text/plain', 'image/png'
        ]
        yield return
  describe '#acceptsEncodings', ->
    it 'should get acceptable encodings from request', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Context extends LeanRC::Context
          @inheritProtected()
          @module Test
        Context.initialize()
        switchInstance =
          configs:
            trustProxy: yes
            cookieKey: 'COOKIE_KEY'
        req =
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'accept-encoding': 'compress, gzip, deflate, sdch, identity'
        res = _headers: {}
        context = Context.new req, res, switchInstance
        assert.deepEqual context.acceptsEncodings(), [
          'compress', 'gzip', 'deflate', 'sdch', 'identity'
        ]
        yield return
  describe '#acceptsCharsets', ->
    it 'should get acceptable charsets from request', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Context extends LeanRC::Context
          @inheritProtected()
          @module Test
        Context.initialize()
        switchInstance =
          configs:
            trustProxy: yes
            cookieKey: 'COOKIE_KEY'
        req =
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'accept-charset': 'utf-8, iso-8859-1;q=0.5, *;q=0.1'
        res = _headers: {}
        context = Context.new req, res, switchInstance
        assert.deepEqual context.acceptsCharsets(), [
          'utf-8', 'iso-8859-1', '*'
        ]
        yield return
  describe '#acceptsLanguages', ->
    it 'should get acceptable languages from request', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Context extends LeanRC::Context
          @inheritProtected()
          @module Test
        Context.initialize()
        switchInstance =
          configs:
            trustProxy: yes
            cookieKey: 'COOKIE_KEY'
        req =
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'accept-language': 'en, ru, cn, fr'
        res = _headers: {}
        context = Context.new req, res, switchInstance
        assert.deepEqual context.acceptsLanguages(), [
          'en', 'ru', 'cn', 'fr'
        ]
        yield return
