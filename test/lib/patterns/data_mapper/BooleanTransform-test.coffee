{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
BooleanTransform = LeanRC::BooleanTransform

describe 'BooleanTransform', ->
  describe '.normalize', ->
    it 'should deserialize null value', ->
      expect BooleanTransform.normalize null
      .to.be.false
    it 'should deserialize boolean value', ->
      expect BooleanTransform.normalize yes
      .to.be.true
    it 'should deserialize string value', ->
      expect BooleanTransform.normalize 'True'
      .to.be.true
    it 'should deserialize number value', ->
      expect BooleanTransform.normalize 1
      .to.be.true
  describe '.serialize', ->
    it 'should serialize null value', ->
      expect BooleanTransform.serialize null
      .to.be.false
    it 'should serialize boolean value', ->
      expect BooleanTransform.serialize yes
      .to.be.true
    it 'should serialize string value', ->
      expect BooleanTransform.serialize 'True'
      .to.be.true
    it 'should serialize number value', ->
      expect BooleanTransform.serialize 1
      .to.be.true
