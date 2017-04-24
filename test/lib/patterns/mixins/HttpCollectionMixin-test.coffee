{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
LeanRC = require.main.require 'lib'
RC = require 'RC'
{ co } = RC::Utils

commonServerInitializer = require.main.require 'test/common/server'
server = commonServerInitializer fixture: 'HttpCollectionMixin'

describe 'HttpCollectionMixin', ->
  describe '.new', ->
    it 'should create HTTP collection instance', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::HttpCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableMixin
          @include LeanRC::HttpCollectionMixin
          @Module: Test
        Test::HttpCollection.initialize()
        collection = Test::HttpCollection.new()
        assert.instanceOf collection, Test::HttpCollection
        yield return
  describe '#~requestToHash, #~makeRequest', ->
    before ->
      server.listen 8000
    after ->
      server.close()
    it 'should make simple request', ->
      co ->
        KEY = 'FACADE_TEST_HTTP_COLLECTION_001'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @Module: Test
          @attribute test: String
          @public init: Function,
            default: ->
              @super arguments...
              @_type = 'Test::TestRecord'
        Test::TestRecord.initialize()
        class Test::HttpCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableMixin
          @include LeanRC::HttpCollectionMixin
          @Module: Test
          @public delegate: RC::Class,
            default: Test::TestRecord
        Test::HttpCollection.initialize()
        facade.registerProxy Test::HttpCollection.new KEY
        collection = facade.retrieveProxy KEY
        assert.instanceOf collection, Test::HttpCollection
        hash = collection[Symbol.for '~requestToHash']
          method: 'GET'
          url: 'http://localhost:8000'
        assert.equal hash.method, 'GET', 'Method is incorrect'
        assert.equal hash.url, 'http://localhost:8000', 'URL is incorrect'
        assert.equal hash.options?.json, yes, 'JSON option is not set'
        data = yield collection[Symbol.for '~makeRequest']
          method: 'GET'
          url: 'http://localhost:8000'
        assert.equal data.status, 200, 'Request received not OK status'
        assert.equal data?.body?.message, 'OK', 'Incorrect body'
        yield return
  describe '#methodForRequest', ->
    it 'should get method name from request params', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::HttpCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableMixin
          @include LeanRC::HttpCollectionMixin
          @Module: Test
        Test::HttpCollection.initialize()
        collection = Test::HttpCollection.new()
        method = collection.methodForRequest requestType: 'find'
        assert.equal method, 'GET', 'Find method is incorrect'
        method = collection.methodForRequest requestType: 'insert'
        assert.equal method, 'POST', 'Insert method is incorrect'
        method = collection.methodForRequest requestType: 'update'
        assert.equal method, 'PATCH', 'Update method is incorrect'
        method = collection.methodForRequest requestType: 'replace'
        assert.equal method, 'PUT', 'Replace method is incorrect'
        method = collection.methodForRequest requestType: 'remove'
        assert.equal method, 'DELETE', 'Remove method is incorrect'
        method = collection.methodForRequest requestType: 'someOther'
        assert.equal method, 'GET', 'Any other method is incorrect'
        yield return
  describe '#~urlPrefix', ->
    it 'should get url prefix', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::HttpCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableMixin
          @include LeanRC::HttpCollectionMixin
          @Module: Test
          @public host: String, { default: 'http://localhost:8000' }
          @public namespace: String, { default: 'v1' }
        Test::HttpCollection.initialize()
        collection = Test::HttpCollection.new()
        url = collection[Symbol.for '~urlPrefix'] 'Test', 'Tests'
        assert.equal url, 'Tests/Test'
        url = collection[Symbol.for '~urlPrefix'] '/Test'
        assert.equal url, 'http://localhost:8000/Test'
        url = collection[Symbol.for '~urlPrefix']()
        assert.equal url, 'http://localhost:8000/v1'
        yield return
  describe '#pathForType', ->
    it 'should get url prefix', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::HttpCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableMixin
          @include LeanRC::HttpCollectionMixin
          @Module: Test
          @public host: String, { default: 'http://localhost:8000' }
          @public namespace: String, { default: 'v1' }
        Test::HttpCollection.initialize()
        collection = Test::HttpCollection.new()
        url = collection.pathForType 'Type'
        assert.equal url, 'types'
        url = collection.pathForType 'TestRecord'
        assert.equal url, 'test_records'
        url = collection.pathForType 'test-info'
        assert.equal url, 'test_infos'
        yield return
  describe '#~buildURL', ->
    it 'should get url from request params', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::HttpCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableMixin
          @include LeanRC::HttpCollectionMixin
          @Module: Test
          @public host: String, { default: 'http://localhost:8000' }
          @public namespace: String, { default: 'v1' }
        Test::HttpCollection.initialize()
        collection = Test::HttpCollection.new()
        url = collection[Symbol.for '~buildURL'] 'Test', {}
        assert.equal url, 'http://localhost:8000/v1/tests/bulk'
        url = collection[Symbol.for '~buildURL'] 'Test', {}, no
        assert.equal url, 'http://localhost:8000/v1/tests'
        yield return
  describe '#urlForFind', ->
    it 'should get url for find request', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::HttpCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableMixin
          @include LeanRC::HttpCollectionMixin
          @Module: Test
          @public host: String, { default: 'http://localhost:8000' }
          @public namespace: String, { default: 'v1' }
        Test::HttpCollection.initialize()
        collection = Test::HttpCollection.new()
        url = collection.urlForFind 'Test', {}
        assert.equal url, 'http://localhost:8000/v1/tests'
        url = collection.urlForFind 'TestRecord', {}
        assert.equal url, 'http://localhost:8000/v1/test_records'
        yield return
  describe '#urlForInsert', ->
    it 'should get url for insert request', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::HttpCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableMixin
          @include LeanRC::HttpCollectionMixin
          @Module: Test
          @public host: String, { default: 'http://localhost:8000' }
          @public namespace: String, { default: 'v1' }
        Test::HttpCollection.initialize()
        collection = Test::HttpCollection.new()
        url = collection.urlForInsert 'Test', {}
        assert.equal url, 'http://localhost:8000/v1/tests'
        url = collection.urlForInsert 'TestRecord', {}
        assert.equal url, 'http://localhost:8000/v1/test_records'
        yield return
  describe '#urlForUpdate', ->
    it 'should get url for insert request', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::HttpCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableMixin
          @include LeanRC::HttpCollectionMixin
          @Module: Test
          @public host: String, { default: 'http://localhost:8000' }
          @public namespace: String, { default: 'v1' }
        Test::HttpCollection.initialize()
        collection = Test::HttpCollection.new()
        url = collection.urlForUpdate 'Test', {}
        assert.equal url, 'http://localhost:8000/v1/tests/bulk'
        url = collection.urlForUpdate 'TestRecord', {}
        assert.equal url, 'http://localhost:8000/v1/test_records/bulk'
        yield return
  describe '#urlForReplace', ->
    it 'should get url for insert request', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::HttpCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableMixin
          @include LeanRC::HttpCollectionMixin
          @Module: Test
          @public host: String, { default: 'http://localhost:8000' }
          @public namespace: String, { default: 'v1' }
        Test::HttpCollection.initialize()
        collection = Test::HttpCollection.new()
        url = collection.urlForReplace 'Test', {}
        assert.equal url, 'http://localhost:8000/v1/tests/bulk'
        url = collection.urlForReplace 'TestRecord', {}
        assert.equal url, 'http://localhost:8000/v1/test_records/bulk'
        yield return
  describe '#urlForRemove', ->
    it 'should get url for insert request', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::HttpCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableMixin
          @include LeanRC::HttpCollectionMixin
          @Module: Test
          @public host: String, { default: 'http://localhost:8000' }
          @public namespace: String, { default: 'v1' }
        Test::HttpCollection.initialize()
        collection = Test::HttpCollection.new()
        url = collection.urlForRemove 'Test', {}
        assert.equal url, 'http://localhost:8000/v1/tests/bulk'
        url = collection.urlForRemove 'TestRecord', {}
        assert.equal url, 'http://localhost:8000/v1/test_records/bulk'
        yield return
  describe '#buildURL', ->
    it 'should get url from request params', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::HttpCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableMixin
          @include LeanRC::HttpCollectionMixin
          @Module: Test
          @public host: String, { default: 'http://localhost:8000' }
          @public namespace: String, { default: 'v1' }
          @public urlForTest: Function,
            default: (recordName, snapshot, requestType, query) ->
              "TEST_#{recordName ? 'RECORD_NAME'}_#{snapshot ? 'SNAPSHOT'}_#{requestType ? 'REQUEST_TYPE'}_#{query ? 'QUERY'}"
        Test::HttpCollection.initialize()
        collection = Test::HttpCollection.new()
        url = collection.buildURL 'Test', {}, 'find', {}
        assert.equal url, 'http://localhost:8000/v1/tests'
        url = collection.buildURL 'Test', {}, 'insert', {}
        assert.equal url, 'http://localhost:8000/v1/tests'
        url = collection.buildURL 'Test', {}, 'update', {}
        assert.equal url, 'http://localhost:8000/v1/tests/bulk'
        url = collection.buildURL 'Test', {}, 'replace', {}
        assert.equal url, 'http://localhost:8000/v1/tests/bulk'
        url = collection.buildURL 'Test', {}, 'remove', {}
        assert.equal url, 'http://localhost:8000/v1/tests/bulk'
        url = collection.buildURL 'Test', 'SNAP', 'test', 'QUE'
        assert.equal url, 'TEST_Test_SNAP_test_QUE'
        yield return
  describe '#urlForRequest', ->
    ###
    it 'should get method name from request params', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::HttpCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableMixin
          @include LeanRC::HttpCollectionMixin
          @Module: Test
        Test::HttpCollection.initialize()
        collection = Test::HttpCollection.new()
        method = collection.urlForRequest requestType: 'find'
        assert.equal method, 'GET', 'Find method is incorrect'
        method = collection.urlForRequest requestType: 'insert'
        assert.equal method, 'POST', 'Insert method is incorrect'
        method = collection.urlForRequest requestType: 'update'
        assert.equal method, 'PATCH', 'Update method is incorrect'
        method = collection.urlForRequest requestType: 'replace'
        assert.equal method, 'PUT', 'Replace method is incorrect'
        method = collection.urlForRequest requestType: 'remove'
        assert.equal method, 'DELETE', 'Remove method is incorrect'
        method = collection.urlForRequest requestType: 'someOther'
        assert.equal method, 'GET', 'Any other method is incorrect'
        yield return
    ###
