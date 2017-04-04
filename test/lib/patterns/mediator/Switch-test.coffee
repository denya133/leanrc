{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
Switch = LeanRC::Switch

describe 'Switch', ->
  describe '.new', ->
    it 'should create new pipeSwitch', ->
      expect ->
        mediatorName = 'TEST_MEDIATOR'
        pipeSwitch = Switch.new mediatorName
      .to.not.throw Error
  describe '#responseFormats', ->
    it 'should check allowed response formats', ->
      expect ->
        mediatorName = 'TEST_MEDIATOR'
        pipeSwitch = Switch.new mediatorName
        assert.deepEqual pipeSwitch.responseFormats, [
          'json', 'html', 'xml', 'atom'
        ], 'Property `responseFormats` returns incorrect values'
      .to.not.throw Error
  describe '#listNotificationInterests', ->
    it 'should check handled notifications list', ->
      expect ->
        mediatorName = 'TEST_MEDIATOR'
        pipeSwitch = Switch.new mediatorName
        assert.deepEqual pipeSwitch.listNotificationInterests(), [
          LeanRC::Constants.HANDLER_RESULT
        ], 'Function `listNotificationInterests` returns incorrect values'
      .to.not.throw Error
