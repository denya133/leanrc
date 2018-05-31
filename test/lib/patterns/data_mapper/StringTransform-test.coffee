{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
StringTransform = LeanRC::StringTransform

describe 'StringTransform', ->
  describe '.normalize', ->
    it 'should normalize null value', ->
      expect StringTransform.normalize null
      .to.be.null
    it 'should normalize boolean value', ->
      expect StringTransform.normalize yes
      .to.equal 'true'
    it 'should normalize string value', ->
      expect StringTransform.normalize 'True'
      .to.equal 'True'
    it 'should normalize number value', ->
      expect StringTransform.normalize 1
      .to.equal '1'
  describe '.serialize', ->
    it 'should serialize null value', ->
      expect StringTransform.serialize null
      .to.be.null
    it 'should serialize boolean value', ->
      expect StringTransform.serialize yes
      .to.equal 'true'
    it 'should serialize string value', ->
      expect StringTransform.serialize 'True'
      .to.equal 'True'
    it 'should serialize number value', ->
      expect StringTransform.serialize 1
      .to.equal '1'
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
