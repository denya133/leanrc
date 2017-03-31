{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
Collection = LeanRC::Collection

describe 'Collection', ->
  describe '.new', ->
    it 'should create collection instance', ->
      expect ->
        collection = Collection.new {}
        console.log 'Schema:', Collection.schema
      .to.not.throw Error
