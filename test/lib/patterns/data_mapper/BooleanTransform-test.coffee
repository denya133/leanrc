{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
{ co, joi } = LeanRC::Utils
BooleanTransform = LeanRC::BooleanTransform

describe 'BooleanTransform', ->
  describe '.schema', ->
    it 'should has correct schema value', ->
      expect BooleanTransform.schema
      .deep.equal joi.boolean().empty(null).default(null)
  describe '.normalize', ->
    it 'should deserialize null value', ->
      co ->
        assert.isFalse yield BooleanTransform.normalize null
        yield return
    it 'should deserialize boolean value', ->
      co ->
        assert.isTrue yield BooleanTransform.normalize yes
        yield return
    it 'should deserialize string value', ->
      co ->
        assert.isTrue yield BooleanTransform.normalize 'True'
        yield return
    it 'should deserialize number value', ->
      co ->
        assert.isTrue yield BooleanTransform.normalize 1
        yield return
  describe '.serialize', ->
    it 'should serialize null value', ->
      co ->
        assert.isFalse yield BooleanTransform.serialize null
        yield return
    it 'should serialize boolean value', ->
      co ->
        assert.isTrue yield BooleanTransform.serialize yes
        yield return
    it 'should serialize string value', ->
      co ->
        assert.isTrue yield BooleanTransform.serialize 'True'
        yield return
    it 'should serialize number value', ->
      co ->
        assert.isTrue yield BooleanTransform.serialize 1
        yield return
  describe '.objectize', ->
    it 'should objectize null value', ->
      expect BooleanTransform.objectize null
      .to.be.false
    it 'should objectize boolean value', ->
      expect BooleanTransform.objectize yes
      .to.be.true
    it 'should objectize string value', ->
      expect BooleanTransform.objectize 'True'
      .to.be.true
    it 'should objectize number value', ->
      expect BooleanTransform.objectize 1
      .to.be.true
