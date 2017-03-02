{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require '../lib'
Notification = LeanRC::Notification
Observer = LeanRC::Observer
Facade = LeanRC::Facade

NOTIFIER_NAME = 'NOTIFIER_NAME'
NOTIFICATION_NAME = 'TEST_NOTIFICATION'

describe 'Observer', ->
  describe '.new', ->
    it 'should create new observer', ->
      expect ->
        context = {}
        notifyMethod = ->
        observer = Observer.new notifyMethod, context
      .to.not.throw Error
  describe '#getNotifyMethod', ->
    it 'should get observer notify method', ->
      context = {}
      notifyMethod = ->
      observer = Observer.new notifyMethod, context
      expect observer.getNotifyMethod()
      .to.equal notifyMethod
  describe '#setNotifyMethod', ->
    it 'should set observer notify method', ->
      notifyMethod = ->
      observer = Observer.new()
      observer.setNotifyMethod notifyMethod
      expect observer.getNotifyMethod()
      .to.equal notifyMethod
  describe '#getNotifyContext', ->
    it 'should get observer notify context', ->
      context = {}
      notifyMethod = ->
      observer = Observer.new notifyMethod, context
      expect observer.getNotifyContext()
      .to.equal context
  describe '#setNotifyContext', ->
    it 'should set observer notify context', ->
      context = {}
      observer = Observer.new()
      observer.setNotifyContext context
      expect observer.getNotifyContext()
      .to.equal context
  describe '#notifyObserver', ->
    it 'should send notification', ->
      expect ->
        notifyMethod = (notification) ->
          @notify notification
        context =
          notify: ->
        notifyMethodSpy = sinon.spy context, 'notify'
        observer = Observer.new notifyMethod, context
        notification = Notification.new 'TEST_NOTIFY_OBSERVER'
        observer.notifyObserver notification
        assert notifyMethodSpy.calledWith notification
      .to.not.throw Error
