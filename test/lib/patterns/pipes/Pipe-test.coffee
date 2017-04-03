{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
Pipe = LeanRC::Pipe

describe 'Pipe', ->
  describe '.new', ->
    it 'should create new Pipe instance', ->
      expect ->
        voOutput = {}
        pipe = Pipe.new voOutput
        assert.equal pipe[Symbol.for 'output'], voOutput, 'Output object is lost'
      .to.not.throw Error
