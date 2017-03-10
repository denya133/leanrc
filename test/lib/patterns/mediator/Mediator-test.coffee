{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
Mediator = LeanRC::Mediator

describe 'Mediator', ->
  describe '.new', ->
    it 'should create new mediator', ->
      expect ->
        mediatorName = 'TEST_MEDIATOR'
        viewComponent = { id: 'view-component' }
        mediator = Mediator.new mediatorName, viewComponent
      .to.not.throw Error
  describe '#getMediatorName', ->
    it 'should get mediator name', ->
      mediatorName = 'TEST_MEDIATOR'
      viewComponent = { id: 'view-component' }
      mediator = Mediator.new mediatorName, viewComponent
      expect mediator.getMediatorName()
      .to.equal mediatorName
  describe '#getViewComponent', ->
    it 'should get mediator view component', ->
      mediatorName = 'TEST_MEDIATOR'
      viewComponent = { id: 'view-component' }
      mediator = Mediator.new mediatorName, viewComponent
      expect mediator.getViewComponent()
      .to.equal viewComponent
  describe '#listNotificationInterests', ->
    it 'should get mediator motification interests list', ->
      class TestMediator extends Mediator
        @inheritProtected()
        @public listNotificationInterests: Function,
          default: -> [ 'TEST1' , 'TEST2', 'TEST3' ]
      mediatorName = 'TEST_MEDIATOR'
      viewComponent = { id: 'view-component' }
      mediator = TestMediator.new mediatorName, viewComponent
      expect mediator.listNotificationInterests()
      .to.eql [ 'TEST1' , 'TEST2', 'TEST3' ]
  describe '#handleNotification', ->
    it 'should call handleNotification', ->
      expect ->
        mediatorName = 'TEST_MEDIATOR'
        viewComponent = { id: 'view-component' }
        mediator = Mediator.new mediatorName, viewComponent
        handleNotification = sinon.spy mediator, 'handleNotification'
        mediator.handleNotification()
        assert handleNotification.called
      .to.not.throw Error
  describe '#onRegister', ->
    it 'should call onRegister', ->
      expect ->
        mediatorName = 'TEST_MEDIATOR'
        viewComponent = { id: 'view-component' }
        mediator = Mediator.new mediatorName, viewComponent
        onRegister = sinon.spy mediator, 'onRegister'
        mediator.onRegister()
        assert onRegister.called
      .to.not.throw Error
  describe '#onRemove', ->
    it 'should call onRemove', ->
      expect ->
        mediatorName = 'TEST_MEDIATOR'
        viewComponent = { id: 'view-component' }
        mediator = Mediator.new mediatorName, viewComponent
        onRemove = sinon.spy mediator, 'onRemove'
        mediator.onRemove()
        assert onRemove.called
      .to.not.throw Error