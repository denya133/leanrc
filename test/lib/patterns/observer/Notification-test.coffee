{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
Notification = LeanRC::Notification

NOTIFICATION_NAME = 'TEST_NOTIFICATION'
NOTIFICATION_BODY =
  body: 'body'
NOTIFICATION_TYPE = 'TEST'

describe 'Notification', ->
  describe '.new', ->
    it 'should create new notification', ->
      expect ->
        notification = Notification.new NOTIFICATION_NAME, NOTIFICATION_BODY, NOTIFICATION_TYPE
      .to.not.throw Error
  describe '#getName', ->
    it 'should get notification name', ->
      notification = Notification.new NOTIFICATION_NAME, NOTIFICATION_BODY, NOTIFICATION_TYPE
      expect notification.getName()
      .to.equal NOTIFICATION_NAME
  describe '#getBody', ->
    it 'should get notification body', ->
      notification = Notification.new NOTIFICATION_NAME, NOTIFICATION_BODY, NOTIFICATION_TYPE
      expect notification.getBody()
      .to.equal NOTIFICATION_BODY
  describe '#setBody', ->
    it 'should set notification body', ->
      notification = Notification.new NOTIFICATION_NAME
      notification.setBody NOTIFICATION_BODY
      expect notification.getBody()
      .to.equal NOTIFICATION_BODY
  describe '#getType', ->
    it 'should get notification type', ->
      notification = Notification.new NOTIFICATION_NAME, NOTIFICATION_BODY, NOTIFICATION_TYPE
      expect notification.getType()
      .to.equal NOTIFICATION_TYPE
  describe '#setType', ->
    it 'should set notification type', ->
      notification = Notification.new NOTIFICATION_NAME
      notification.setType NOTIFICATION_TYPE
      expect notification.getType()
      .to.equal NOTIFICATION_TYPE
