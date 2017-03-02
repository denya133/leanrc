{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require '../lib'
View = LeanRC::View
Notification = LeanRC::Notification
Observer = LeanRC::Observer
Mediator = LeanRC::Mediator

describe 'View', ->
  describe '.getInstance', ->
    it 'should get new or existing instance of View', ->
      expect ->
        view = View.getInstance 'TEST1'
        assert view instanceof View, 'The `view` is not an instance of View'
      .to.not.throw Error
  describe '.removeView', ->
    it 'should get new instance of View, remove it and get new one', ->
      expect ->
        view = View.getInstance 'TEST2'
        oldView = View.getInstance 'TEST2'
        assert view is oldView, 'View is not saved'
        View.removeView 'TEST2'
        newView = View.getInstance 'TEST2'
        assert view isnt newView, 'View instance didn\'t renewed'
      .to.not.throw Error
  describe '#registerObserver', ->
    it 'should register new observer', ->
      expect ->
        view = View.getInstance 'TEST3'
        notifyMethod = sinon.spy()
        notifyMethod.reset()
        context = {}
        observer = Observer.new notifyMethod, context
        notification = Notification.new 'TEST_VIEW'
        view.registerObserver notification.getName(), observer
        view.notifyObservers notification
        assert notifyMethod.called, 'Observer is not registered'
      .to.not.throw Error
  describe '#removeObserver', ->
    it 'should register new observer', ->
      expect ->
        view = View.getInstance 'TEST4'
        notifyMethod = sinon.spy()
        notifyMethod.reset()
        context = {}
        observer = Observer.new notifyMethod, context
        notification = Notification.new 'TEST_VIEW'
        view.registerObserver notification.getName(), observer
        view.removeObserver notification.getName(), observer.getNotifyContext()
        view.notifyObservers notification
        assert not notifyMethod.called, 'Observer is not removed'
      .to.not.throw Error
  describe '#registerMediator', ->
    it 'should register new mediator', ->
      expect ->
        view = View.getInstance 'TEST5'
        onRegister = sinon.spy()
        handleNotification = sinon.spy()
        viewComponent = {}
        class TestMediator extends Mediator
          @inheritProtected()
          @public listNotificationInterests: Function,
            default: -> [ 'TEST_LIST' ]
          @public handleNotification: Function,
            default: handleNotification
          @public onRegister: Function,
            default: onRegister
        mediator = TestMediator.new 'TEST_MEDIATOR', viewComponent
        view.registerMediator mediator
        assert onRegister.called, 'Mediator is not registered'
        onRegister.reset()
        view.notifyObservers Notification.new 'TEST_LIST'
        assert handleNotification.called, 'Mediator cannot subscribe interests'
      .to.not.throw Error
  describe '#retrieveMediator', ->
    it 'should retrieve registred mediator', ->
      expect ->
        view = View.getInstance 'TEST6'
        viewComponent = {}
        class TestMediator extends Mediator
          @inheritProtected()
        view.registerMediator TestMediator.new 'TEST_MEDIATOR', viewComponent
        retrievedMediator = view.retrieveMediator 'TEST_MEDIATOR'
        assert retrievedMediator?, 'Cannot retrieve mediator'
        retrievedAbsentMediator = view.retrieveMediator 'TEST_MEDIATOR_ABSENT'
        assert not retrievedAbsentMediator?, 'Retrieve absent mediator'
      .to.not.throw Error
  describe '#removeMediator', ->
    it 'should remove mediator', ->
      expect ->
        view = View.getInstance 'TEST7'
        onRegister = sinon.spy()
        onRemove = sinon.spy()
        viewComponent = {}
        class TestMediator extends Mediator
          @inheritProtected()
          @public onRegister: Function,
            default: onRegister
          @public onRemove: Function,
            default: onRemove
        mediator = TestMediator.new 'TEST_MEDIATOR', viewComponent
        view.registerMediator mediator
        assert onRegister.called, 'Mediator is not registered'
        onRegister.reset()
        view.removeMediator 'TEST_MEDIATOR'
        assert onRemove.called, 'Mediator onRemove hook not called'
        hasMediator = view.hasMediator 'TEST_MEDIATOR'
        assert not hasMediator, 'Mediator didn\'t removed'
      .to.not.throw Error
