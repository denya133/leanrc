{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils

describe 'GenerateAutoincrementIdMixin', ->
  facade = null
  after -> facade?.remove?()
  describe '#generateId', ->
    it 'should generate id for itemsusing autoincrement', ->
      co ->
        KEY = 'FACADE_TEST_AUTOINCREMENT_ID_001'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @public init: Function,
            default: ->
              @super arguments...
              @type = 'Test::TestRecord'
        Test::TestRecord.initialize()
        class Test::Queryable extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableCollectionMixin
          @include LeanRC::GenerateAutoincrementIdMixin
          @module Test
          @public delegate: LeanRC::Class,
            default: Test::TestRecord
          @public parseQuery: Object,
            default: (aoQuery) -> aoQuery
          @public @async executeQuery: LeanRC::Cursor,
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
          @public take: Function,
            default: (id) ->
              data = _.find @getData(), { id }
              throw new Error 'NOT_FOUND'  unless data?
              yield data
          @public push: Function,
            default: (record) ->
              @getData().push @delegate.serialize record
              yield return
        Test::Queryable.initialize()
        facade.registerProxy Test::Queryable.new KEY, []
        collection = facade.retrieveProxy KEY
        for i in [ 1 .. 10 ]
          { id } = yield collection.create()
          assert.equal i, id
        yield return
