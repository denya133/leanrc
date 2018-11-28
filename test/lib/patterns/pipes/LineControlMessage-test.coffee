{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
LineControlMessage = LeanRC::Pipes::LineControlMessage

describe 'LineControlMessage', ->
  describe '.new', ->
    it 'should create new LineControlMessage instance', ->
      expect ->
        vsType = LineControlMessage.FIFO
        message = LineControlMessage.new vsType
        assert.equal message[Symbol.for '~type'], vsType, 'Type is incorrect'
      .to.not.throw Error
