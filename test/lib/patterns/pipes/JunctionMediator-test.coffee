{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
JunctionMediator = LeanRC::JunctionMediator

describe 'JunctionMediator', ->
  describe '.new', ->
    it 'should create new JunctionMediator instance', ->
      expect ->
        JunctionMediator.new()
      .to.not.throw Error
  describe '#listNotificationInterests', ->
    it 'should get acceptable notifications', ->
      expect ->
        mediator = JunctionMediator.new()
        assert.deepEqual mediator.listNotificationInterests(), [
          JunctionMediator.ACCEPT_INPUT_PIPE
          JunctionMediator.ACCEPT_OUTPUT_PIPE
          JunctionMediator.REMOVE_PIPE
        ], 'Acceptable notifications list is incorrect'
      .to.not.throw Error
