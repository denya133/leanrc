{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
PipeMessage = LeanRC::PipeMessage

describe 'PipeMessage', ->
  describe '.new', ->
    it 'should create new PipeMessage instance', ->
      expect ->
        vnPriority = PipeMessage.PRIORITY_MED
        vsType = PipeMessage.NORMAL
        voHeader = header: 'test'
        voBody = message: 'TEST'
        message = PipeMessage.new vsType, voHeader, voBody, vnPriority
        assert.equal message[Symbol.for 'type'], vsType, 'Type is incorrect'
        assert.equal message[Symbol.for 'priority'], vnPriority, 'Priority is incorrect'
        assert.equal message[Symbol.for 'header'], voHeader, 'Header is incorrect'
        assert.equal message[Symbol.for 'body'], voBody, 'Body is incorrect'
      .to.not.throw Error
  describe '#getType, #setType', ->
    it 'should create new message and check type', ->
      expect ->
        vsType = PipeMessage.NORMAL
        vsTypeUpdated = PipeMessage.HIGH
        message = PipeMessage.new vsType
        assert.equal message[Symbol.for 'type'], vsType, 'Type is incorrect'
        assert.equal message[Symbol.for 'type'], message.getType(), 'Type is incorrect'
        message.setType vsTypeUpdated
        assert.equal message.getType(), vsTypeUpdated, 'Type is incorrect'
      .to.not.throw Error
  describe '#getHeader, #setHeader', ->
    it 'should create new message and set and get header', ->
      expect ->
        voHeader = header: 'test'
        message = PipeMessage.new PipeMessage.NORMAL
        message.setHeader voHeader
        assert.equal message[Symbol.for 'header'], message.getHeader(), 'Header is incorrect'
        assert.equal message.getHeader(), voHeader, 'Header is incorrect'
      .to.not.throw Error

  describe '#getBody, #setBody', ->
    it 'should create new message and set and get body', ->
      expect ->
        voBody = body: 'test'
        message = PipeMessage.new PipeMessage.NORMAL
        message.setBody voBody
        assert.equal message[Symbol.for 'body'], message.getBody(), 'Body is incorrect'
        assert.equal message.getBody(), voBody, 'Body is incorrect'
      .to.not.throw Error
