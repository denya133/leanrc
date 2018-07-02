{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
{ co, joi } = LeanRC::Utils
DateTransform = LeanRC::DateTransform

describe 'DateTransform', ->
  describe '.schema', ->
    it 'should has correct schema value', ->
      expect DateTransform.schema
      .deep.equal joi.date().iso().allow(null).optional()
  describe '.normalize', ->
    it 'should deserialize null value', ->
      co ->
        assert.equal (yield DateTransform.normalize null), null
        yield return
    it 'should deserialize date value', ->
      co ->
        date = new Date
        assert.deepEqual (yield DateTransform.normalize date.toISOString()), date
        yield return
    it 'should deserialize boolean value', ->
      co ->
        assert.deepEqual (yield DateTransform.normalize yes), new Date 1
        yield return
    it 'should deserialize string value', ->
      co ->
        assert.deepEqual (yield DateTransform.normalize 'True'), new Date ''
        yield return
    it 'should deserialize number value', ->
      co ->
        assert.deepEqual (yield DateTransform.normalize 1), new Date 1
        yield return
  describe '.serialize', ->
    it 'should serialize null value', ->
      co ->
        assert.equal (yield DateTransform.serialize null), null
        yield return
    it 'should serialize date value', ->
      co ->
        date = new Date
        assert.equal (yield DateTransform.serialize date), date.toISOString()
        yield return
    it 'should serialize boolean value', ->
      co ->
        assert.equal (yield DateTransform.serialize yes), null
        yield return
    it 'should serialize string value', ->
      co ->
        assert.equal (yield DateTransform.serialize 'True'), null
        yield return
    it 'should serialize number value', ->
      co ->
        assert.equal (yield DateTransform.serialize 1), null
        yield return
  describe '.objectize', ->
    it 'should objectize null value', ->
      expect DateTransform.objectize null
      .to.be.null
    it 'should objectize date value', ->
      date = new Date
      expect DateTransform.objectize date
      .to.eql date.toISOString()
    it 'should objectize boolean value', ->
      expect DateTransform.objectize yes
      .to.be.null
    it 'should objectize string value', ->
      expect DateTransform.objectize 'True'
      .to.be.null
    it 'should objectize number value', ->
      expect DateTransform.objectize 1
      .to.be.null
