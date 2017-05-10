{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
RC = require 'RC'
{ co } = RC::Utils

describe 'IterableMixin', ->
  describe '.new', ->
    it 'should create iterable instance', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
        Test::TestRecord.initialize()
        class Test::Iterable extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::IterableMixin
          @module Test
          ipcRecord = @protected record: Test::TestRecord
          iplArray = @protected array: Array
          @public init: Function,
            default: (args...) ->
              @super args...
              [vcRecord, vlArray] = args
              @[ipcRecord] = vcRecord
              @[iplArray] = vlArray
          @public @async takeAll: Function,
            default: ->
              yield RC::Promise.resolve LeanRC::Cursor.new @[ipcRecord], @[iplArray]
        Test::Iterable.initialize()
        array = [ {}, {}, {} ]
        iterable = Test::Iterable.new Test::TestRecord, array
        cursor = yield iterable.takeAll()
        assert.equal (yield cursor.count()), 3, 'Records length does not match'
        return
  describe '#forEach', ->
    it 'should call lambda in each record in iterable', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute data: String, { default: '' }
        Test::TestRecord.initialize()
        class Test::Iterable extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::IterableMixin
          @module Test
          ipcRecord = @protected record: Test::TestRecord
          iplArray = @protected array: Array
          @public init: Function,
            default: (args...) ->
              @super args...
              [vcRecord, vlArray] = args
              @[ipcRecord] = vcRecord
              @[iplArray] = vlArray
          @public @async takeAll: Function,
            default: ->
              yield RC::Promise.resolve LeanRC::Cursor.new @[ipcRecord], @[iplArray]
        Test::Iterable.initialize()
        array = [ { data: 'three' }, { data: 'men' }, { data: 'in' }, { data: 'a boat' } ]
        iterable = Test::Iterable.new Test::TestRecord, array
        spyLambda = sinon.spy -> yield return
        yield iterable.forEach spyLambda
        assert.isTrue spyLambda.called, 'Lambda never called'
        assert.equal spyLambda.callCount, 4, 'Lambda calls are not match'
        assert.equal spyLambda.args[0][0].data, 'three', 'Lambda 1st call is not match'
        assert.equal spyLambda.args[1][0].data, 'men', 'Lambda 2nd call is not match'
        assert.equal spyLambda.args[2][0].data, 'in', 'Lambda 3rd call is not match'
        assert.equal spyLambda.args[3][0].data, 'a boat', 'Lambda 4th call is not match'
        return
  describe '#map', ->
    it 'should map records using lambda', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute data: String, { default: '' }
        Test::TestRecord.initialize()
        class Test::Iterable extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::IterableMixin
          @module Test
          ipcRecord = @protected record: Test::TestRecord
          iplArray = @protected array: Array
          @public init: Function,
            default: (args...) ->
              @super args...
              [vcRecord, vlArray] = args
              @[ipcRecord] = vcRecord
              @[iplArray] = vlArray
          @public @async takeAll: Function,
            default: ->
              yield RC::Promise.resolve LeanRC::Cursor.new @[ipcRecord], @[iplArray]
        Test::Iterable.initialize()
        array = [ { data: 'three' }, { data: 'men' }, { data: 'in' }, { data: 'a boat' } ]
        iterable = Test::Iterable.new Test::TestRecord, array
        records = yield iterable.map (record) ->
          record.data = '+' + record.data + '+'
          yield RC::Promise.resolve record
        assert.lengthOf records, 4, 'Records count is not match'
        assert.equal records[0].data, '+three+', '1st record is not match'
        assert.equal records[1].data, '+men+', '2nd record is not match'
        assert.equal records[2].data, '+in+', '3rd record is not match'
        assert.equal records[3].data, '+a boat+', '4th record is not match'
        return
  describe '#filter', ->
    it 'should filter records using lambda', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute data: String, { default: '' }
        Test::TestRecord.initialize()
        class Test::Iterable extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::IterableMixin
          @module Test
          ipcRecord = @protected record: Test::TestRecord
          iplArray = @protected array: Array
          @public init: Function,
            default: (args...) ->
              @super args...
              [vcRecord, vlArray] = args
              @[ipcRecord] = vcRecord
              @[iplArray] = vlArray
          @public @async takeAll: Function,
            default: ->
              yield RC::Promise.resolve LeanRC::Cursor.new @[ipcRecord], @[iplArray]
        Test::Iterable.initialize()
        array = [ { data: 'three' }, { data: 'men' }, { data: 'in' }, { data: 'a boat' } ]
        iterable = Test::Iterable.new Test::TestRecord, array
        records = yield iterable.filter (record) ->
          yield RC::Promise.resolve record.data.length > 3
        assert.lengthOf records, 2, 'Records count is not match'
        assert.equal records[0].data, 'three', '1st record is not match'
        assert.equal records[1].data, 'a boat', '2nd record is not match'
        return
  describe '#reduce', ->
    it 'should reduce records using lambda', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute data: String, { default: '' }
        Test::TestRecord.initialize()
        class Test::Iterable extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::IterableMixin
          @module Test
          ipcRecord = @protected record: Test::TestRecord
          iplArray = @protected array: Array
          @public init: Function,
            default: (args...) ->
              @super args...
              [vcRecord, vlArray] = args
              @[ipcRecord] = vcRecord
              @[iplArray] = vlArray
          @public @async takeAll: Function,
            default: ->
              yield RC::Promise.resolve LeanRC::Cursor.new @[ipcRecord], @[iplArray]
        Test::Iterable.initialize()
        array = [ { data: 'three' }, { data: 'men' }, { data: 'in' }, { data: 'a boat' } ]
        iterable = Test::Iterable.new Test::TestRecord, array
        records = yield iterable.reduce (accumulator, item) ->
          accumulator[item.data] = item
          yield RC::Promise.resolve accumulator
        , {}
        assert.equal records['three'].data, 'three', '1st record is not match'
        assert.equal records['men'].data, 'men', '2nd record is not match'
        assert.equal records['in'].data, 'in', '3rd record is not match'
        assert.equal records['a boat'].data, 'a boat', '4th record is not match'
        return
