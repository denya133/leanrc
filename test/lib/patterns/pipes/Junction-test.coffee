{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
Junction = LeanRC::Junction

describe 'Junction', ->
  describe '.new', ->
    it 'should create new Junction instance', ->
      expect ->
        junction = Junction.new()
      .to.not.throw Error
