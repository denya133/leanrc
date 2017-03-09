{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
DateTransform = LeanRC::DateTransform

describe 'DateTransform', ->
  describe '.new', ->
    it 'should create new boolean transform', ->
      expect ->
        transform = DateTransform.new()
      .to.not.throw Error
  describe '#deserialize', ->
    it 'should deserialize null value', ->
      expect DateTransform.new().deserialize null
      .to.be.null
    it 'should deserialize date value', ->
      date = new Date
      expect DateTransform.new().deserialize date.toISOString()
      .to.eql date
    it 'should deserialize boolean value', ->
      expect DateTransform.new().deserialize yes
      .to.eql new Date 1
    it 'should deserialize string value', ->
      expect DateTransform.new().deserialize 'True'
      .to.be.NaN
    it 'should deserialize number value', ->
      expect DateTransform.new().deserialize 1
      .to.eql new Date 1
  describe '#serialize', ->
    it 'should serialize null value', ->
      expect DateTransform.new().serialize null
      .to.be.null
    it 'should serialize date value', ->
      date = new Date
      expect DateTransform.new().serialize date
      .to.eql date.toISOString()
    it 'should serialize boolean value', ->
      expect DateTransform.new().serialize yes
      .to.be.null
    it 'should serialize string value', ->
      expect DateTransform.new().serialize 'True'
      .to.be.null
    it 'should serialize number value', ->
      expect DateTransform.new().serialize 1
      .to.be.null
