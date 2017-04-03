{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
Filter = LeanRC::Filter

describe 'Filter', ->
  describe '.new', ->
    it 'should create new Filter instance', ->
      expect ->
        filter = Filter.new 'TEST'
        assert.equal filter[Symbol.for 'name'], 'TEST', 'Filter name is incorrect'
      .to.not.throw Error
