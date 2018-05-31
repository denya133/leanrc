{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils
Transform = LeanRC::Transform

describe 'Transform', ->
  describe '.normalize', ->
    it 'should normalize null value', ->
      co ->
        assert.equal (yield Transform.normalize null), null
        yield return
    it 'should normalize boolean value', ->
      co ->
        assert.equal (yield Transform.normalize yes), true
        yield return
    it 'should normalize string value', ->
      co ->
        assert.equal (yield Transform.normalize 'True'), 'True'
        yield return
    it 'should normalize number value', ->
      co ->
        assert.equal (yield Transform.normalize 1), 1
        yield return
  describe '.serialize', ->
    it 'should serialize null value', ->
      co ->
        assert.equal (yield Transform.serialize null), null
        yield return
    it 'should serialize boolean value', ->
      co ->
        assert.equal (yield Transform.normalize yes), true
        yield return
    it 'should serialize string value', ->
      co ->
        assert.equal (yield Transform.normalize 'True'), 'True'
        yield return
    it 'should serialize number value', ->
      co ->
        assert.equal (yield Transform.normalize 1), 1
        yield return
  describe '.objectize', ->
    it 'should objectize null value', ->
      expect Transform.objectize null
      .to.be.null
    it 'should objectize boolean value', ->
      expect Transform.objectize yes
      .to.be.true
    it 'should objectize string value', ->
      expect Transform.objectize 'True'
      .to.equal 'True'
    it 'should objectize number value', ->
      expect Transform.objectize 1
      .to.equal 1
