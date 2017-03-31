{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
Record = LeanRC::Record

describe 'Record', ->
  ###
  describe '.new', ->
    it 'should create record instance', ->
      expect ->
        record = Record.new {}
        console.log 'Schema:', Record.schema
      .to.not.throw Error
  ###
