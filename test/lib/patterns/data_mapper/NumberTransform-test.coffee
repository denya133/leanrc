{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
NumberTransform = LeanRC::NumberTransform

describe 'NumberTransform', ->
  describe '.normalize', ->
    it 'should normalize null value', ->
      expect NumberTransform.normalize null
      .to.be.null
    it 'should normalize boolean value', ->
      expect NumberTransform.normalize yes
      .to.equal 1
    it 'should normalize string value', ->
      expect NumberTransform.normalize 'True'
      .to.be.NaN
    it 'should normalize number value', ->
      expect NumberTransform.normalize 1
      .to.equal 1
  describe '.serialize', ->
    it 'should serialize null value', ->
      expect NumberTransform.serialize null
      .to.be.null
    it 'should serialize boolean value', ->
      expect NumberTransform.serialize yes
      .to.equal 1
    it 'should serialize string value', ->
      expect NumberTransform.serialize 'True'
      .to.be.NaN
    it 'should serialize number value', ->
      expect NumberTransform.serialize 1
      .to.equal 1
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
