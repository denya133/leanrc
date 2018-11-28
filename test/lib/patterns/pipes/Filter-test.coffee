{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
Filter = LeanRC::Pipes::Filter
Pipe = LeanRC::Pipes::Pipe
FilterControlMessage = LeanRC::Pipes::FilterControlMessage

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
          output = Pipe.new()
          filter = Filter.new 'TEST', output, (aoMessage) -> aoMessage
          message = FilterControlMessage.new LeanRC::Pipes::PipeMessage.NORMAL, 'TEST'
          stubWrite = sinon.stub output, 'write'
            .returns yes
          filter.write message
          assert.isTrue stubWrite.calledWith(message), '#write not called'
        .to.not.throw Error
    describe 'if message type is `LeanRC::FilterControlMessage.SET_PARAMS`', ->
      it 'should get message and update filter params', ->
        expect ->
          output = Pipe.new()
          testParams = test: 'test1'
          filter = Filter.new 'TEST', output, (aoMessage) -> aoMessage
          message = FilterControlMessage.new FilterControlMessage.SET_PARAMS, 'TEST'
          message.setParams testParams
          stubWrite = sinon.stub output, 'write'
            .returns yes
          filter.write message
          assert.isFalse stubWrite.calledWith(message), '#write called'
          assert.equal filter[Symbol.for '~params'], testParams, 'params are incorrect'
        .to.not.throw Error
    describe 'if message type is `LeanRC::FilterControlMessage.SET_FILTER`', ->
      it 'should get message and update filter function', ->
        expect ->
          output = Pipe.new()
          testFilter = (aoMessage) -> aoMessage
          spyFilter = sinon.spy testFilter
          filter = Filter.new 'TEST', output
          message = FilterControlMessage.new FilterControlMessage.SET_FILTER, 'TEST'
          message.setFilter testFilter
          stubWrite = sinon.stub output, 'write'
            .returns yes
          filter.write message
          assert.isFalse stubWrite.calledWith(message), '#write called'
          assert.equal filter[Symbol.for '~filter'], testFilter, 'filter function is incorrect'
        .to.not.throw Error
    describe 'if message type is `LeanRC::FilterControlMessage.BYPASS` or `LeanRC::FilterControlMessage.FILTER`', ->
      it 'should get message and update filter mode', ->
        expect ->
          output = Pipe.new()
          filter = Filter.new 'TEST', output
          message = FilterControlMessage.new FilterControlMessage.BYPASS, 'TEST'
          stubWrite = sinon.stub output, 'write'
            .returns yes
          filter.write message
          assert.isFalse stubWrite.calledWith(message), '#write called'
          assert.equal filter[Symbol.for '~mode'], FilterControlMessage.BYPASS, 'filter mode is incorrect'
          output = Pipe.new()
          filter = Filter.new 'TEST', output
          message = FilterControlMessage.new FilterControlMessage.FILTER, 'TEST'
          stubWrite = sinon.stub output, 'write'
            .returns yes
          filter.write message
          assert.isFalse stubWrite.calledWith(message), '#write called'
          assert.equal filter[Symbol.for '~mode'], FilterControlMessage.FILTER, 'filter mode is incorrect'
        .to.not.throw Error
