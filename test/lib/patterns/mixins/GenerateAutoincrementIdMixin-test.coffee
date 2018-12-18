{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
LeanRC = require.main.require 'lib'
{
  NilT
  FuncG, SubsetG, UnionG,
  RecordInterface, QueryInterface, CursorInterface, CollectionInterface
  Utils: { co }
} = LeanRC::

describe 'GenerateAutoincrementIdMixin', ->
  describe '#generateId', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should generate id for itemsusing autoincrement', ->
      co ->
        KEY = 'FACADE_TEST_AUTOINCREMENT_ID_001'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @public init: FuncG([Object, CollectionInterface], NilT),
            default: ->
              @super arguments...
              @type = 'Test::TestRecord'
              return
          @initialize()
        class Queryable extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableCollectionMixin
          @include LeanRC::GenerateAutoincrementIdMixin
          @module Test
          @public delegate: SubsetG(RecordInterface),
            default: TestRecord
          @public @async parseQuery: FuncG(
            [UnionG Object, QueryInterface]
            UnionG Object, String, QueryInterface
          ),
            default: (aoQuery) -> yield return aoQuery
          @public @async executeQuery: FuncG(
            [UnionG Object, String, QueryInterface]
            CursorInterface
          ),
            default: (aoParsedQuery) ->
              data = []
              isCustomReturn = no
              if (property = aoParsedQuery['$max'])?
                isCustomReturn = yes
                property = property.replace '@doc.', ''
                sorted = _.sortBy @getData(), (doc) -> doc[property]
                doc = _.last sorted
                data.push doc[property]  if doc?
              voCursor = if isCustomReturn
                LeanRC::Cursor.new null, data
              else
                LeanRC::Cursor.new @, data
              yield return voCursor
          @public @async take: FuncG([UnionG String, Number], RecordInterface),
            default: (id) ->
              data = _.find @getData(), { id }
              throw new Error 'NOT_FOUND'  unless data?
              yield data
          @public @async push: FuncG(RecordInterface, RecordInterface),
            default: (record) ->
              item = yield @delegate.serialize record
              @getData().push item
              yield return record
          @initialize()
        facade.registerProxy Queryable.new KEY, []
        collection = facade.retrieveProxy KEY
        for i in [ 1 .. 10 ]
          { id } = yield collection.create({type: 'Test::TestRecord'})
          assert.equal i, id
        yield return
