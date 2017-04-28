{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
Pipe = LeanRC::Pipes::Pipe
TeeMerge = LeanRC::Pipes::TeeMerge

describe 'TeeMerge', ->
  describe '.new', ->
    it 'should create new TeeMerge instance', ->
      expect ->
        merge = TeeMerge.new()
      .to.not.throw Error
  describe '#connectInput', ->
    it 'should create new TeeMerge instance', ->
      expect ->
        voInput1 = Pipe.new()
        voInput2 = Pipe.new()
        merge = TeeMerge.new voInput1, voInput2
        assert.equal voInput1[Symbol.for '~output'], merge, 'Input 1 not connected'
        assert.equal voInput2[Symbol.for '~output'], merge, 'Input 2 not connected'
      .to.not.throw Error
