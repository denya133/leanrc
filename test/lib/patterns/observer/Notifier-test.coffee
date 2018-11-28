{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'

{
  Notifier
  Facade
} = LeanRC::

NOTIFICATION_NAME = 'TEST_NOTIFICATION'
NOTIFICATION_BODY =
  body: 'body'
NOTIFICATION_TYPE = 'TEST'

describe 'Notifier', ->
  describe '.new', ->
    before ->
      facade = Facade.getInstance 'NOTIFIER_TEST_1'
    after ->
      facade = Facade.getInstance 'NOTIFIER_TEST_1'
      facade.remove()
    it 'should create new notifier', ->
      expect ->
        notifier = Notifier.new()
        notifier.initializeNotifier 'NOTIFIER_TEST_1'
        return
      .to.not.throw Error
  describe '#sendNotification', ->
    spyCall = null
    before ->
      facade = Facade.getInstance 'NOTIFIER_TEST_2'
      spyCall = sinon.spy facade, 'sendNotification'
    after ->
      facade = Facade.getInstance 'NOTIFIER_TEST_2'
      facade.remove()
    it 'should send notification', ->
      expect ->
        facade = Facade.getInstance 'NOTIFIER_TEST_2'
        notifier = Notifier.new()
        notifier.initializeNotifier 'NOTIFIER_TEST_2'
        notifier.sendNotification NOTIFICATION_NAME, NOTIFICATION_BODY, NOTIFICATION_TYPE
        assert.isTrue spyCall.calledWith(NOTIFICATION_NAME, NOTIFICATION_BODY, NOTIFICATION_TYPE), 'facade.sendNotification called incorrect'
        return
      .to.not.throw Error
