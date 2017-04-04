{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
Queue = LeanRC::Queue

describe 'Queue', ->
  describe '.new', ->
    it 'should create new Queue instance', ->
      expect ->
        voOutput = {}
        pipe = Queue.new voOutput
        assert.equal pipe[Symbol.for 'output'], voOutput, 'Output object is lost'
      .to.not.throw Error
