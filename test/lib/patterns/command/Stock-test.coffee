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
