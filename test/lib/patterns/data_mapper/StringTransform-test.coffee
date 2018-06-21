{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
{ co, joi } = LeanRC::Utils
StringTransform = LeanRC::StringTransform

describe 'StringTransform', ->
  describe '.schema', ->
    it 'should has correct schema value', ->
      expect StringTransform.schema
      .deep.equal joi.string().allow(null).optional()
  describe '.normalize', ->
    it 'should normalize null value', ->
      co ->
        assert.equal (yield StringTransform.normalize null), null
        yield return
    it 'should normalize boolean value', ->
      co ->
        assert.equal (yield StringTransform.normalize yes), 'true'
        yield return
    it 'should normalize string value', ->
      co ->
        assert.equal (yield StringTransform.normalize 'True'), 'True'
        yield return
    it 'should normalize number value', ->
      co ->
        assert.equal (yield StringTransform.normalize 1), '1'
        yield return
  describe '.serialize', ->
    it 'should serialize null value', ->
      co ->
        assert.equal (yield StringTransform.serialize null), null
        yield return
    it 'should serialize boolean value', ->
      co ->
        assert.equal (yield StringTransform.serialize yes), 'true'
        yield return
    it 'should serialize string value', ->
      co ->
        assert.equal (yield StringTransform.serialize 'True'), 'True'
        yield return
    it 'should serialize number value', ->
      co ->
        assert.equal (yield StringTransform.serialize 1), '1'
        yield return
  describe '.objectize', ->
    it 'should objectize null value', ->
      expect StringTransform.objectize null
      .to.be.null
    it 'should objectize boolean value', ->
      expect StringTransform.objectize yes
      .to.equal 'true'
    it 'should objectize string value', ->
      expect StringTransform.objectize 'True'
      .to.equal 'True'
    it 'should objectize number value', ->
      expect StringTransform.objectize 1
      .to.equal '1'
