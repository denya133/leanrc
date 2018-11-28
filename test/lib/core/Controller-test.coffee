{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
{
  APPLICATION_MEDIATOR
  FuncG
  NotificationInterface
  Controller
  SimpleCommand
  Notification
  Utils: { co }
} = LeanRC::

describe 'Controller', ->
  describe '.getInstance', ->
    it 'should get new or existing instance of Controller', ->
      expect ->
        controller = Controller.getInstance 'TEST1'
        unless controller instanceof Controller
          throw new Error 'The `controller` is not an instance of Controller'
      .to.not.throw Error
  describe '.removeController', ->
    it 'should get new instance of Controller, remove it and get new one', ->
      expect ->
        controller = Controller.getInstance 'TEST2'
        Controller.removeController 'TEST2'
        newController = Controller.getInstance 'TEST2'
        if controller is newController
          throw new Error 'Controller instance didn\'t renewed'
      .to.not.throw Error
  describe '#registerCommand', ->
    it 'should register new command', ->
      expect ->
        controller = Controller.getInstance 'TEST3'
        class TestCommand extends SimpleCommand
          @inheritProtected()
          @public execute: FuncG(NotificationInterface),
            default: ->
        controller.registerCommand 'TEST_COMMAND', TestCommand
        assert controller.hasCommand 'TEST_COMMAND'
        return
      .to.not.throw Error
  describe '#lazyRegisterCommand', ->
    # facade = null
    INSTANCE_NAME = 'TEST3'
    before ->
      LeanRC::Facade.getInstance INSTANCE_NAME
    after ->
      LeanRC::Facade.getInstance INSTANCE_NAME
        .remove()
    it 'should register new command lazily', ->
      co ->
        spy = sinon.spy()
        {
          NilT, FuncG, NotificationInterface
        } = LeanRC::
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestCommand extends SimpleCommand
          @inheritProtected()
          @module Test
          @public execute: FuncG(NotificationInterface, NilT),
            default: spy
          @initialize()
        class Application extends Test::CoreObject
          @inheritProtected()
          @module Test
          @initialize()
        facade = Test::Facade.getInstance INSTANCE_NAME
        controller = Controller.getInstance INSTANCE_NAME
        facade.registerMediator Test::Mediator.new APPLICATION_MEDIATOR, Application.new()
        notification = new Notification 'TEST_COMMAND2'
        controller.lazyRegisterCommand notification.getName(), 'TestCommand'
        assert controller.hasCommand notification.getName()
        controller.executeCommand notification
        assert spy.called
        spy.reset()
        notification = new Notification 'TestCommand'
        controller.lazyRegisterCommand notification.getName()
        assert controller.hasCommand notification.getName()
        controller.executeCommand notification
        assert spy.called
        yield return
  describe '#executeCommand', ->
    it 'should register new command and call it', ->
      expect ->
        controller = Controller.getInstance 'TEST4'
        spy = sinon.spy()
        spy.reset()
        class TestCommand extends SimpleCommand
          @inheritProtected()
          @public execute: FuncG(NotificationInterface),
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
        controller = Controller.getInstance 'TEST5'
        class TestCommand extends SimpleCommand
          @inheritProtected()
          @public execute: FuncG(NotificationInterface),
            default: ->
        controller.removeCommand 'TEST_COMMAND'
        controller.removeCommand 'TEST_COMMAND1'
        assert not controller.hasCommand 'TEST_COMMAND'
        assert not controller.hasCommand 'TEST_COMMAND1'
        return
      .to.not.throw Error
  describe '#hasCommand', ->
    it 'should register new command', ->
      expect ->
        controller = Controller.getInstance 'TEST6'
        class TestCommand extends SimpleCommand
          @inheritProtected()
        controller.registerCommand 'TEST_COMMAND', TestCommand
        assert controller.hasCommand 'TEST_COMMAND'
        assert not controller.hasCommand 'TEST_COMMAND_ABSENT'
        return
      .to.not.throw Error
