{ expect, assert } = require 'chai'
LeanRC = require '../lib'
Controller = LeanRC::Controller

describe 'Controller', ->
  describe '.getInstance', ->
    it 'should get new or existing instance of Controller', ->
      expect ->
        controller = Controller.getInstance 'TEST'
        unless controller instanceof Controller
          throw new Error 'The `controller` is not an instance of Controller'
      .to.not.throw Error
