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
  describe '.removeController', ->
    it 'should get new instance of Controller, remove it and get new one', ->
      expect ->
        controller = Controller.getInstance 'TEST'
        Controller.removeController 'TEST'
        newController = Controller.getInstance 'TEST'
        if controller is newController
          throw new Error 'Controller instance didn\'t renewed'
      .to.not.throw Error
