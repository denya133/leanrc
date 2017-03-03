{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require '../lib'
Facade = LeanRC::Facade
SimpleCommand = LeanRC::SimpleCommand
Notification = LeanRC::Notification

describe 'Facade', ->
  describe '.getInstance', ->
    it 'should get new or existing instance of Facade', ->
      expect ->
        facade = Facade.getInstance 'TEST1'
        assert facade instanceof Facade, 'The `facade` is not an instance of Facade'
        facade1 = Facade.getInstance 'TEST1'
        assert facade is facade1, 'Instances of facade not equal'
      .to.not.throw Error
