{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
Entry = LeanRC::Entry

describe 'Entry', ->
  describe '.new', ->
    it 'should create entry instance', ->
      expect ->
        entry = Entry.new {}
        assert.property Entry.attributes, 'id', 'No `id` attribute'
        assert.property Entry.attributes, 'rev', 'No `rev` attribute'
        assert.property Entry.attributes, 'type', 'No `type` attribute'
        assert.property Entry.attributes, 'isHidden', 'No `isHidden` attribute'
        assert.property Entry.attributes, 'createdAt', 'No `createdAt` attribute'
        assert.property Entry.attributes, 'updatedAt', 'No `updatedAt` attribute'
        assert.property Entry.attributes, 'deletedAt', 'No `deletedAt` attribute'
      .to.not.throw Error
