{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
Serializer = LeanRC::Serializer
Record = LeanRC::Record

describe 'Serializer', ->
  ###
  describe '#normalize', ->
    it "should normalize object value", ->
      serializer = Serializer.new()
      expect serializer.normalize Record, {}
      .to.be.instanceof Record
  describe '#serialize', ->
    it "should serialize Record.prototype value", ->
      serializer = Serializer.new()
      expect serializer.serialize Record::
      .to.be.instanceof Object
  ###
