{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
Filter = LeanRC::Filter
FilterControlMessage = LeanRC::FilterControlMessage

describe 'Filter', ->
  describe '.new', ->
    it 'should create new Filter instance', ->
      expect ->
        filter = Filter.new 'TEST'
        assert.equal filter[Symbol.for '~name'], 'TEST', 'Filter name is incorrect'
        assert.equal filter[Symbol.for '~mode'], FilterControlMessage.FILTER, 'Filter mode is incorrect'
      .to.not.throw Error
  describe '#setFilter', ->
    it 'should create filter and set filter function', ->
      expect ->
        testFilter = ->
        filter = Filter.new 'TEST'
        assert.equal filter[Symbol.for '~name'], 'TEST', 'Filter name is incorrect'
        filter.setFilter testFilter
        assert.equal filter[Symbol.for '~filter'], testFilter, 'Filter is incorrect'
      .to.not.throw Error
  describe '#setParams', ->
    it 'should create filter and set params', ->
      expect ->
        testParams = test: 'test1'
        filter = Filter.new 'TEST'
        assert.equal filter[Symbol.for '~name'], 'TEST', 'Filter name is incorrect'
        filter.setParams testParams
        assert.equal filter[Symbol.for '~params'], testParams, 'Params is incorrect'
      .to.not.throw Error
  describe '#write', ->
    describe 'if message type is `LeanRC::PipeMessage.NORMAL`', ->
      it 'should get message and write it into output', ->
        expect ->
          output = write: ->
          spyWrite = sinon.spy output, 'write'
          filter = Filter.new 'TEST', output, (aoMessage) -> aoMessage
          message = FilterControlMessage.new LeanRC::PipeMessage.NORMAL, 'TEST'
          filter.write message
          assert.isTrue spyWrite.calledWith(message), '#write called incorrectly'
        .to.not.throw Error
    describe 'if message type is `LeanRC::FilterControlMessage.SET_PARAMS`', ->
      it 'should get message and update filter params', ->
        expect ->
          output = write: ->
          spyWrite = sinon.spy output, 'write'
          testParams = test: 'test1'
          filter = Filter.new 'TEST', output, (aoMessage) -> aoMessage
          message = FilterControlMessage.new FilterControlMessage.SET_PARAMS, 'TEST'
          message.setParams testParams
          filter.write message
          assert.isFalse spyWrite.calledWith(message), '#write called'
          assert.equal filter[Symbol.for '~params'], testParams, 'params are incorrect'
        .to.not.throw Error
    describe 'if message type is `LeanRC::FilterControlMessage.SET_FILTER`', ->
      it 'should get message and update filter function', ->
        expect ->
          output = write: ->
          spyWrite = sinon.spy output, 'write'
          testFilter = (aoMessage) -> aoMessage
          spyFilter = sinon.spy testFilter
          filter = Filter.new 'TEST', output
          message = FilterControlMessage.new FilterControlMessage.SET_FILTER, 'TEST'
          message.setFilter testFilter
          filter.write message
          assert.isFalse spyWrite.calledWith(message), '#write called'
          assert.equal filter[Symbol.for '~filter'], testFilter, 'filter function is incorrect'
        .to.not.throw Error
    describe 'if message type is `LeanRC::FilterControlMessage.BYPASS` or `LeanRC::FilterControlMessage.FILTER`', ->
      it 'should get message and update filter mode', ->
        expect ->
          output = write: ->
          spyWrite = sinon.spy output, 'write'
          filter = Filter.new 'TEST', output
          message = FilterControlMessage.new FilterControlMessage.BYPASS, 'TEST'
          filter.write message
          assert.isFalse spyWrite.calledWith(message), '#write called'
          assert.equal filter[Symbol.for '~mode'], FilterControlMessage.BYPASS, 'filter mode is incorrect'
          message = FilterControlMessage.new FilterControlMessage.FILTER, 'TEST'
          filter.write message
          assert.isFalse spyWrite.calledWith(message), '#write called'
          assert.equal filter[Symbol.for '~mode'], FilterControlMessage.FILTER, 'filter mode is incorrect'
        .to.not.throw Error
