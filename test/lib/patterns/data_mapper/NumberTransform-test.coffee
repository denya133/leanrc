{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
{ co, joi } = LeanRC::Utils
NumberTransform = LeanRC::NumberTransform

describe 'NumberTransform', ->
  describe '.schema', ->
    it 'should has correct schema value', ->
      expect NumberTransform.schema
      .deep.equal joi.number().allow(null).optional()
  describe '.normalize', ->
    it 'should normalize null value', ->
      co ->
        assert.equal (yield NumberTransform.normalize null), null
        yield return
    it 'should normalize boolean value', ->
      co ->
        assert.equal (yield NumberTransform.normalize yes), 1
        yield return
    it 'should normalize string value', ->
      co ->
        assert.isNaN (yield NumberTransform.normalize 'True')
        yield return
    it 'should normalize number value', ->
      co ->
        assert.equal (yield NumberTransform.normalize 1), 1
        yield return
  describe '.serialize', ->
    it 'should serialize null value', ->
      co ->
        assert.equal (yield NumberTransform.serialize null), null
        yield return
    it 'should serialize boolean value', ->
      co ->
        assert.equal (yield NumberTransform.serialize yes), 1
        yield return
    it 'should serialize string value', ->
      co ->
        assert.isNaN (yield NumberTransform.serialize 'True')
        yield return
    it 'should serialize number value', ->
      co ->
        assert.equal (yield NumberTransform.serialize 1), 1
        yield return
  describe '.objectize', ->
    it 'should objectize null value', ->
      expect NumberTransform.objectize null
      .to.be.null
    it 'should objectize boolean value', ->
      expect NumberTransform.objectize yes
      .to.equal 1
    it 'should objectize string value', ->
      expect NumberTransform.objectize 'True'
      .to.be.NaN
    it 'should objectize number value', ->
      expect NumberTransform.objectize 1
      .to.equal 1
