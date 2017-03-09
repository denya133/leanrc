{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
Transform = LeanRC::Transform

describe 'Transform', ->
  describe '.new', ->
    it 'should create new boolean transform', ->
      expect ->
        transform = Transform.new()
      .to.not.throw Error
  describe '.deserialize', ->
    it 'should deserialize null value', ->
      expect Transform.new().deserialize null
      .to.equal null
    it 'should deserialize boolean value', ->
      expect Transform.new().deserialize yes
      .to.equal yes
    it 'should deserialize string value', ->
      expect Transform.new().deserialize 'True'
      .to.equal 'True'
    it 'should deserialize number value', ->
      expect Transform.new().deserialize 1
      .to.equal 1
  describe '.serialize', ->
    it 'should serialize null value', ->
      expect Transform.new().serialize null
      .to.equal null
    it 'should serialize boolean value', ->
      expect Transform.new().serialize yes
      .to.equal yes
    it 'should serialize string value', ->
      expect Transform.new().serialize 'True'
      .to.equal 'True'
    it 'should serialize number value', ->
      expect Transform.new().serialize 1
      .to.equal 1
