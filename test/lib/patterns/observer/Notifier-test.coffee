{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
Notification = LeanRC::Notification
Notifier = LeanRC::Notifier

NOTIFIER_NAME = 'NOTIFIER_NAME'
NOTIFICATION_NAME = 'TEST_NOTIFICATION'

describe 'Notifier', ->
  describe '.new', ->
    it 'should create new notifier', ->
      expect ->
        notifier = Notifier.new()
        notifier.initializeNotifier NOTIFIER_NAME
      .to.not.throw Error
  describe '#sendNotification', ->
    it 'should send notification', ->
      expect ->
        notifier = Notifier.new()
        notifier.initializeNotifier NOTIFIER_NAME
        notification = Notification.new NOTIFICATION_NAME
        notifier.sendNotification notification
      .to.not.throw Error
