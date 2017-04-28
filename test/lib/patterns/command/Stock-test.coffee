{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
Stock = LeanRC::Stock
{ co } = LeanRC::Utils

describe 'Stock', ->
  describe '.new', ->
    it 'should create new command', ->
      expect ->
        stock = Stock.new()
      .to.not.throw Error
  describe '#keyName', ->
    it 'should get key name using entity name', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestStock extends LeanRC::Stock
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        Test::TestStock.initialize()
        stock = Test::TestStock.new()
        { keyName } = stock
        assert.equal keyName, 'test_entity'
        yield return
  describe '#itemEntityName', ->
    it 'should get item name using entity name', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestStock extends LeanRC::Stock
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        Test::TestStock.initialize()
        stock = Test::TestStock.new()
        { itemEntityName } = stock
        assert.equal itemEntityName, 'test_entity'
        yield return
  describe '#listEntityName', ->
    it 'should get list name using entity name', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestStock extends LeanRC::Stock
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        Test::TestStock.initialize()
        stock = Test::TestStock.new()
        { listEntityName } = stock
        assert.equal listEntityName, 'test_entities'
        yield return
  describe '#collectionName', ->
    it 'should get collection name using entity name', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestStock extends LeanRC::Stock
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        Test::TestStock.initialize()
        stock = Test::TestStock.new()
        { collectionName } = stock
        assert.equal collectionName, 'TestEntitiesCollection'
        yield return
  describe '#collection', ->
    it 'should get collection', ->
      co ->
        TEST_FACADE = 'TEST_FACADE_001'
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestStock extends LeanRC::Stock
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        Test::TestStock.initialize()
        facade = LeanRC::Facade.getInstance TEST_FACADE
        stock = Test::TestStock.new()
        stock.initializeNotifier TEST_FACADE
        { collectionName } = stock
        boundCollection = LeanRC::Collection.new collectionName
        facade.registerProxy boundCollection
        { collection } = stock
        assert.equal collection, boundCollection
        yield return
  describe '#action', ->
    it 'should create actions', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestStock extends LeanRC::Stock
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
          @action test1: String,
            default: 'test1'
          @action test2: String,
            default: 'test2'
          @action test3: String,
            default: 'test3'
        Test::TestStock.initialize()
        assert.deepEqual Test::TestStock.metaObject.data.actions.test1,
          default: 'test1'
          attr: 'test1'
          attrType: String
          level: LeanRC::PUBLIC
        assert.deepEqual Test::TestStock.metaObject.data.actions.test2,
          default: 'test2'
          attr: 'test2'
          attrType: String
          level: LeanRC::PUBLIC
        assert.deepEqual Test::TestStock.metaObject.data.actions.test3,
          default: 'test3'
          attr: 'test3'
          attrType: String
          level: LeanRC::PUBLIC
        yield return
  describe '#actions', ->
    it 'should get stock actions', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestStock extends LeanRC::Stock
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
          @action test1: String,
            default: 'test1'
          @action test2: String,
            default: 'test2'
          @action test3: String,
            default: 'test3'
        Test::TestStock.initialize()
        assert.deepEqual Test::TestStock.actions.test1,
          default: 'test1'
          attr: 'test1'
          attrType: String
          level: LeanRC::PUBLIC
        assert.deepEqual Test::TestStock.actions.test2,
          default: 'test2'
          attr: 'test2'
          attrType: String
          level: LeanRC::PUBLIC
        assert.deepEqual Test::TestStock.actions.test3,
          default: 'test3'
          attr: 'test3'
          attrType: String
          level: LeanRC::PUBLIC
        { actions } = Test::TestStock
        assert.propertyVal actions.list, 'attr', 'list'
        assert.propertyVal actions.list, 'attrType', Function
        assert.propertyVal actions.list, 'level', LeanRC::PUBLIC
        assert.propertyVal actions.list, 'async', LeanRC::ASYNC
        assert.propertyVal actions.detail, 'attr', 'detail'
        assert.propertyVal actions.detail, 'attrType', Function
        assert.propertyVal actions.detail, 'level', LeanRC::PUBLIC
        assert.propertyVal actions.detail, 'async', LeanRC::ASYNC
        assert.propertyVal actions.create, 'attr', 'create'
        assert.propertyVal actions.create, 'attrType', Function
        assert.propertyVal actions.create, 'level', LeanRC::PUBLIC
        assert.propertyVal actions.create, 'async', LeanRC::ASYNC
        assert.propertyVal actions.update, 'attr', 'update'
        assert.propertyVal actions.update, 'attrType', Function
        assert.propertyVal actions.update, 'level', LeanRC::PUBLIC
        assert.propertyVal actions.update, 'async', LeanRC::ASYNC
        assert.propertyVal actions.delete, 'attr', 'delete'
        assert.propertyVal actions.delete, 'attrType', Function
        assert.propertyVal actions.delete, 'level', LeanRC::PUBLIC
        assert.propertyVal actions.delete, 'async', LeanRC::ASYNC
        assert.propertyVal actions.bulkUpdate, 'attr', 'bulkUpdate'
        assert.propertyVal actions.bulkUpdate, 'attrType', Function
        assert.propertyVal actions.bulkUpdate, 'level', LeanRC::PUBLIC
        assert.propertyVal actions.bulkUpdate, 'async', LeanRC::ASYNC
        assert.propertyVal actions.bulkPatch, 'attr', 'bulkPatch'
        assert.propertyVal actions.bulkPatch, 'attrType', Function
        assert.propertyVal actions.bulkPatch, 'level', LeanRC::PUBLIC
        assert.propertyVal actions.bulkPatch, 'async', LeanRC::ASYNC
        assert.propertyVal actions.bulkDelete, 'attr', 'bulkDelete'
        assert.propertyVal actions.bulkDelete, 'attrType', Function
        assert.propertyVal actions.bulkDelete, 'level', LeanRC::PUBLIC
        assert.propertyVal actions.bulkDelete, 'async', LeanRC::ASYNC
        yield return
  describe '#execute', ->
    ###
    it 'should create new stock', ->
      expect ->
        trigger = sinon.spy()
        trigger.reset()
        class TestStock extends Stock
          @inheritProtected()
          @public execute: Function,
            default: ->
              trigger()
        stock = TestStock.new()
        stock.execute()
        assert trigger.called
      .to.not.throw Error
    ###
