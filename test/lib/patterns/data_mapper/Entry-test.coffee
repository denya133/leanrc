{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
Entry = LeanRC::Entry

describe 'Entry', ->
  ###
  describe '.new', ->
    it 'should create entry instance', ->
      expect ->
        entry = Entry.new {}
        console.log 'Schema:', Entry.schema
      .to.not.throw Error
  ####
