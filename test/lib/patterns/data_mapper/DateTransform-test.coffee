{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
DateTransform = LeanRC::DateTransform

describe 'DateTransform', ->
  describe '.normalize', ->
    it 'should deserialize null value', ->
      expect DateTransform.normalize null
      .to.be.null
    it 'should deserialize date value', ->
      date = new Date
      expect DateTransform.normalize date.toISOString()
      .to.eql date
    it 'should deserialize boolean value', ->
      expect DateTransform.normalize yes
      .to.eql new Date 1
    it 'should deserialize string value', ->
      expect DateTransform.normalize 'True'
      .to.be.NaN
    it 'should deserialize number value', ->
      expect DateTransform.normalize 1
      .to.eql new Date 1
  describe '.serialize', ->
    it 'should serialize null value', ->
      expect DateTransform.serialize null
      .to.be.null
    it 'should serialize date value', ->
      date = new Date
      expect DateTransform.serialize date
      .to.eql date.toISOString()
    it 'should serialize boolean value', ->
      expect DateTransform.serialize yes
      .to.be.null
    it 'should serialize string value', ->
      expect DateTransform.serialize 'True'
      .to.be.null
    it 'should serialize number value', ->
      expect DateTransform.serialize 1
      .to.be.null
