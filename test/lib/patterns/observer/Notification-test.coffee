{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
Notification = LeanRC::Notification
{ co } = LeanRC::Utils

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
  describe '.replicateObject', ->
    it 'should create replica for notification', ->
      co ->
        notification = LeanRC::Notification.new 'XXX', 'YYY', 'ZZZ'
        replica = yield LeanRC::Notification.replicateObject notification
        assert.deepEqual replica, type: 'instance', class: 'Notification'
        yield return
  ###
  describe '.restoreObject', ->
    facade = null
    KEY = 'TEST_SERIALIZER_002'
    after -> facade?.remove?()
    it 'should restore notification from replica', ->
      co ->
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()
        class MyCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
        MyCollection.initialize()
        class MySerializer extends LeanRC::Serializer
          @inheritProtected()
          @module Test
        MySerializer.initialize()
        COLLECTION = 'COLLECTION'
        collection = facade.registerProxy MyCollection.new COLLECTION,
          delegate: Test::Record
          serializer: MySerializer
        collection = facade.retrieveProxy COLLECTION
        restoredRecord = yield MySerializer.restoreObject Test,
          type: 'instance'
          class: 'MySerializer'
          multitonKey: KEY
          collectionName: COLLECTION
        assert.deepEqual collection.serializer, restoredRecord
        yield return
  ###
