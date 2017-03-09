{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
NumberTransform = LeanRC::NumberTransform

describe 'NumberTransform', ->
  describe '.new', ->
    it 'should create new boolean transform', ->
      expect ->
        transform = NumberTransform.new()
      .to.not.throw Error
  describe '.deserialize', ->
    it 'should deserialize null value', ->
      expect NumberTransform.new().deserialize null
      .to.be.null
    it 'should deserialize boolean value', ->
      expect NumberTransform.new().deserialize yes
      .to.equal 1
    it 'should deserialize string value', ->
      expect NumberTransform.new().deserialize 'True'
      .to.be.NaN
    it 'should deserialize number value', ->
      expect NumberTransform.new().deserialize 1
      .to.equal 1
  describe '.serialize', ->
    it 'should serialize null value', ->
      expect NumberTransform.new().serialize null
      .to.be.null
    it 'should serialize boolean value', ->
      expect NumberTransform.new().serialize yes
      .to.equal 1
    it 'should serialize string value', ->
      expect NumberTransform.new().serialize 'True'
      .to.be.NaN
    it 'should serialize number value', ->
      expect NumberTransform.new().serialize 1
      .to.equal 1
