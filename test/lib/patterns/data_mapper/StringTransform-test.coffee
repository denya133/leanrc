{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
StringTransform = LeanRC::StringTransform

describe 'StringTransform', ->
  describe '.new', ->
    it 'should create new boolean transform', ->
      expect ->
        transform = StringTransform.new()
      .to.not.throw Error
  describe '#deserialize', ->
    it 'should deserialize null value', ->
      expect StringTransform.new().deserialize null
      .to.be.null
    it 'should deserialize boolean value', ->
      expect StringTransform.new().deserialize yes
      .to.equal 'true'
    it 'should deserialize string value', ->
      expect StringTransform.new().deserialize 'True'
      .to.equal 'True'
    it 'should deserialize number value', ->
      expect StringTransform.new().deserialize 1
      .to.equal '1'
  describe '#serialize', ->
    it 'should serialize null value', ->
      expect StringTransform.new().serialize null
      .to.be.null
    it 'should serialize boolean value', ->
      expect StringTransform.new().serialize yes
      .to.equal 'true'
    it 'should serialize string value', ->
      expect StringTransform.new().serialize 'True'
      .to.equal 'True'
    it 'should serialize number value', ->
      expect StringTransform.new().serialize 1
      .to.equal '1'
