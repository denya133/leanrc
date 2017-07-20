{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
Transform = LeanRC::Transform

describe 'Transform', ->
  describe '.normalize', ->
    it 'should normalize null value', ->
      expect Transform.normalize null
      .to.be.null
    it 'should normalize boolean value', ->
      expect Transform.normalize yes
      .to.be.true
    it 'should normalize string value', ->
      expect Transform.normalize 'True'
      .to.equal 'True'
    it 'should normalize number value', ->
      expect Transform.normalize 1
      .to.equal 1
  describe '.serialize', ->
    it 'should serialize null value', ->
      expect Transform.serialize null
      .to.be.null
    it 'should serialize boolean value', ->
      expect Transform.serialize yes
      .to.be.true
    it 'should serialize string value', ->
      expect Transform.serialize 'True'
      .to.equal 'True'
    it 'should serialize number value', ->
      expect Transform.serialize 1
      .to.equal 1
