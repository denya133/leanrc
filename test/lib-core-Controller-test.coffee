{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require '../lib'
Controller = LeanRC::Controller
SimpleCommand = LeanRC::SimpleCommand
Notification = LeanRC::Notification

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
  describe '#registerCommand', ->
    it 'should register new command', ->
      expect ->
        controller = Controller.getInstance 'TEST'
        class TestCommand extends SimpleCommand
          @inheritProtected()
          @public execute: Function,
            default: ->
        controller.registerCommand 'TEST_COMMAND', TestCommand
        assert controller.hasCommand 'TEST_COMMAND'
        return
      .to.not.throw Error
  describe '#executeCommand', ->
    it 'should register new command and call it', ->
      expect ->
        controller = Controller.getInstance 'TEST'
        spy = sinon.spy()
        spy.reset()
        class TestCommand extends SimpleCommand
          @inheritProtected()
          @public execute: Function,
            default: spy
        notification = new Notification 'TEST_COMMAND1'
        controller.registerCommand notification.getName(), TestCommand
        controller.executeCommand notification
        assert spy.called
        return
      .to.not.throw Error
  describe '#removeCommand', ->
    it 'should remove command if present', ->
      expect ->
        controller = Controller.getInstance 'TEST'
        class TestCommand extends SimpleCommand
          @inheritProtected()
          @public execute: Function,
            default: ->
        controller.removeCommand 'TEST_COMMAND'
        controller.removeCommand 'TEST_COMMAND1'
        assert not controller.hasCommand 'TEST_COMMAND'
        assert not controller.hasCommand 'TEST_COMMAND1'
        return
      .to.not.throw Error
