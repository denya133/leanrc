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
