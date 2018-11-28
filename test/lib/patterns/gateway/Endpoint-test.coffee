{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
{
  Endpoint,
  Utils: { co, joi }
} = LeanRC::

describe 'Endpoint', ->
  describe '.new', ->
    it 'should create new endpoint', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../proxy/config/lib"
          @initialize()
        gateway = Test::Gateway.new 'TEST_GATEWAY'#, endpoints: {}
        # gateway = test: 'test'
        endpoint = Endpoint.new { gateway }
        # assert.equal endpoint.gateway, gateway, 'Gateway is incorrect'
        assert.instanceOf endpoint, Endpoint
        yield return
  describe '#tag', ->
    it 'should create endpoint and add tag', ->
      expect ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../proxy/config/lib"
          @initialize()
        gateway = Test::Gateway.new 'TEST_GATEWAY'#, endpoints: {}
        # gateway = test: 'test'
        endpoint = Endpoint.new { gateway }
        tag = 'ENDPOINT_TAG'
        assert.notInclude endpoint.tags ? [], tag, 'Endpoint already contains tag'
        endpoint.tag tag
        assert.include endpoint.tags, tag, 'Endpoint does not contain tag'
      .to.not.throw Error
  describe '#header', ->
    it 'should create endpoint and add header', ->
      expect ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../proxy/config/lib"
          @initialize()
        gateway = Test::Gateway.new 'TEST_GATEWAY'#, endpoints: {}
        # gateway = test: 'test'
        endpoint = Endpoint.new { gateway }
        header = name: 'NAME', schema: joi.object(), description: 'DESCRIPTION'
        assert.notInclude endpoint.headers ? [], header, 'Endpoint already contains header'
        endpoint.header header.name, header.schema, header.description
        assert.include endpoint.headers, header, 'Endpoint does not contain header'
      .to.not.throw Error
  describe '#pathParam', ->
    it 'should create endpoint and add pathParam', ->
      expect ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../proxy/config/lib"
          @initialize()
        gateway = Test::Gateway.new 'TEST_GATEWAY'#, endpoints: {}
        # gateway = test: 'test'
        endpoint = Endpoint.new { gateway }
        pathParam = name: 'NAME', schema: joi.string(), description: 'DESCRIPTION'
        assert.notInclude endpoint.pathParams ? [], pathParam, 'Endpoint already contains pathParam'
        endpoint.pathParam pathParam.name, pathParam.schema, pathParam.description
        assert.include endpoint.pathParams, pathParam, 'Endpoint does not contain pathParam'
      .to.not.throw Error
  describe '#response', ->
    it 'should create endpoint and add response', ->
      expect ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../proxy/config/lib"
          @initialize()
        gateway = Test::Gateway.new 'TEST_GATEWAY'#, endpoints: {}
        # gateway = test: 'test'
        endpoint = Endpoint.new { gateway }
        response = status: 200, schema: joi.object(), mimes: [ 'text/plain' ], description: 'DESCRIPTION'
        assert.notInclude endpoint.responses ? [], response, 'Endpoint already contains response'
        endpoint.response response.status, response.schema, response.mimes, response.description
        assert.include endpoint.responses, response, 'Endpoint does not contain response'
      .to.not.throw Error
  describe '#body', ->
    it 'should create endpoint and add body', ->
      expect ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../proxy/config/lib"
          @initialize()
        gateway = Test::Gateway.new 'TEST_GATEWAY'#, endpoints: {}
        # gateway = test: 'test'
        endpoint = Endpoint.new { gateway }
        body = schema: joi.object(), mimes: [ 'text/plain' ], description: 'DESCRIPTION'
        assert.notDeepEqual endpoint.payload, body, 'Endpoint already contains body'
        endpoint.body body.schema, body.mimes, body.description
        assert.deepEqual endpoint.payload, body, 'Endpoint does not contain body'
      .to.not.throw Error
  describe '#summary', ->
    it 'should create endpoint and add summary', ->
      expect ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../proxy/config/lib"
          @initialize()
        gateway = Test::Gateway.new 'TEST_GATEWAY'#, endpoints: {}
        # gateway = test: 'test'
        endpoint = Endpoint.new { gateway }
        summary = 'TEST_SUMMARY'
        assert.notEqual endpoint.title, summary, 'Endpoint already contains summary'
        endpoint.summary summary
        assert.equal endpoint.title, summary, 'Endpoint does not contain summary'
      .to.not.throw Error
  describe '#description', ->
    it 'should create endpoint and add description', ->
      expect ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../proxy/config/lib"
          @initialize()
        gateway = Test::Gateway.new 'TEST_GATEWAY'#, endpoints: {}
        # gateway = test: 'test'
        endpoint = Endpoint.new { gateway }
        description = 'TEST_DESCRIPTION'
        assert.notEqual endpoint.synopsis, description, 'Endpoint already contains description'
        endpoint.description description
        assert.equal endpoint.synopsis, description, 'Endpoint does not contain description'
      .to.not.throw Error
  describe '#deprecated', ->
    it 'should create endpoint and add deprecated', ->
      expect ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../proxy/config/lib"
          @initialize()
        gateway = Test::Gateway.new 'TEST_GATEWAY'#, endpoints: {}
        # gateway = test: 'test'
        endpoint = Endpoint.new { gateway }
        assert.isFalse endpoint.isDeprecated, 'Endpoint already deprecated'
        endpoint.deprecated yes
        assert.isTrue endpoint.isDeprecated, 'Endpoint is not deprecated'
        endpoint.deprecated no
        assert.isFalse endpoint.isDeprecated, 'Endpoint is deprecated'
      .to.not.throw Error
