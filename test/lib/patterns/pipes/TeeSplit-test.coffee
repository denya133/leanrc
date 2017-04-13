{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
TeeSplit = LeanRC::TeeSplit
PipeMessage = LeanRC::PipeMessage

describe 'TeeSplit', ->
  describe '.new', ->
    it 'should create new TeeSplit instance', ->
      expect ->
        voOutput1 = write: ->
        voOutput2 = write: ->
        split = TeeSplit.new voOutput1, voOutput2
        assert.include split[Symbol.for '~outputs'], voOutput1, 'Output 1 not connected'
        assert.include split[Symbol.for '~outputs'], voOutput2, 'Output 2 not connected'
      .to.not.throw Error
  describe '#connect', ->
    it 'should add new output to splitter', ->
      expect ->
        voOutput1 = write: ->
        voOutput2 = write: ->
        voOutput3 = write: ->
        split = TeeSplit.new voOutput1, voOutput2
        assert.include split[Symbol.for '~outputs'], voOutput1, 'Output 1 not connected'
        assert.include split[Symbol.for '~outputs'], voOutput2, 'Output 2 not connected'
        split.connect voOutput3
        assert.include split[Symbol.for '~outputs'], voOutput3, 'Output 3 not connected'
      .to.not.throw Error
  describe '#disconnect', ->
    it 'should remove last output from splitter', ->
      expect ->
        voOutput1 = id: 1, write: ->
        voOutput2 = id: 2, write: ->
        voOutput3 = id: 3, write: ->
        split = TeeSplit.new voOutput1, voOutput2
        assert.include split[Symbol.for '~outputs'], voOutput1, 'Output 1 not connected'
        assert.include split[Symbol.for '~outputs'], voOutput2, 'Output 2 not connected'
        split.connect voOutput3
        assert.include split[Symbol.for '~outputs'], voOutput3, 'Output 3 not connected'
        split.disconnect()
        assert.notInclude split[Symbol.for '~outputs'], voOutput3, 'Output 3 still connected'
      .to.not.throw Error
  describe '#disconnectFitting', ->
    it 'should remove single output from splitter', ->
      expect ->
        voOutput1 = id: 1, write: ->
        spyWrite1 = sinon.spy voOutput1, 'write'
        voOutput2 = id: 2, write: ->
        spyWrite1 = sinon.spy voOutput2, 'write'
        voOutput3 = id: 3, write: ->
        spyWrite1 = sinon.spy voOutput3, 'write'
        split = TeeSplit.new voOutput1, voOutput2
        assert.include split[Symbol.for '~outputs'], voOutput1, 'Output 1 not connected'
        assert.include split[Symbol.for '~outputs'], voOutput2, 'Output 2 not connected'
        split.connect voOutput3
        assert.include split[Symbol.for '~outputs'], voOutput3, 'Output 3 not connected'
        split.disconnectFitting voOutput2
        assert.notInclude split[Symbol.for '~outputs'], voOutput2, 'Output 2 still connected'
      .to.not.throw Error
  describe '#write', ->
    it 'should send message into all connected pipes', ->
      expect ->
        voOutput1 = id: 1, write: ->
        spyWrite1 = sinon.spy voOutput1, 'write'
        voOutput2 = id: 2, write: ->
        spyWrite2 = sinon.spy voOutput2, 'write'
        split = TeeSplit.new voOutput1, voOutput2
        message = PipeMessage.new PipeMessage.NORMAL
        split.write message
        assert.isTrue spyWrite1.called, 'Output 1 not receied message'
        assert.isTrue spyWrite2.called, 'Output 2 not receied message'
      .to.not.throw Error
