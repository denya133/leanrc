{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils

describe 'LoggingJunctionMixin', ->
  describe '.new', ->
    it 'should create new JunctionMediator instance with LoggingJunctionMixin', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class TestJunctionMediator extends LeanRC::Pipes::JunctionMediator
          @inheritProtected()
          @include LeanRC::LoggingJunctionMixin
          @module Test
        TestJunctionMediator.initialize()
        mediator = TestJunctionMediator.new 'TEST_MEDIATOR', LeanRC::Pipes::Junction.new()
        assert.instanceOf mediator, LeanRC::Pipes::JunctionMediator
        assert.instanceOf mediator[Symbol.for '~junction'], LeanRC::Pipes::Junction
        yield return
  describe '#listNotificationInterests', ->
    it 'should get list of mediator notification interesets', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class TestJunctionMediator extends LeanRC::Pipes::JunctionMediator
          @inheritProtected()
          @include LeanRC::LoggingJunctionMixin
          @module Test
        TestJunctionMediator.initialize()
        mediator = TestJunctionMediator.new 'TEST_MEDIATOR', LeanRC::Pipes::Junction.new()
        assert.deepEqual mediator.listNotificationInterests(), [
          LeanRC::Pipes::JunctionMediator.ACCEPT_INPUT_PIPE
          LeanRC::Pipes::JunctionMediator.ACCEPT_OUTPUT_PIPE
          LeanRC::Pipes::JunctionMediator.REMOVE_PIPE
          LeanRC::LogMessage.SEND_TO_LOG
          LeanRC::Pipes::LogFilterMessage.SET_LOG_LEVEL
        ]
        yield return
  describe '#handleNotification', ->
    it 'should handle send-to-log notification (debug)', ->
      co ->
        KEY = 'TEST_LOGGING_JUNCTION_MIXIN_001'
        TEST_BODY = 'TEST_BODY'
        class Test extends LeanRC
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class TestJunctionMediator extends LeanRC::Pipes::JunctionMediator
          @inheritProtected()
          @include LeanRC::LoggingJunctionMixin
          @module Test
        TestJunctionMediator.initialize()
        junction = LeanRC::Pipes::Junction.new()
        sinon.spy junction, 'sendMessage'
        mediator = TestJunctionMediator.new 'TEST_MEDIATOR', junction
        mediator.initializeNotifier KEY
        notification = LeanRC::Notification.new LeanRC::LogMessage.SEND_TO_LOG, TEST_BODY, LeanRC::LogMessage.LEVELS[LeanRC::LogMessage.DEBUG]
        mediator.handleNotification notification
        [ vsOutputPipeName, voMessage ] = junction.sendMessage.args[0]
        assert.equal vsOutputPipeName, LeanRC::Pipes::PipeAwareModule.STDLOG
        assert.propertyVal voMessage, 'logLevel', LeanRC::LogMessage.DEBUG
        assert.propertyVal voMessage, 'sender', KEY
        assert.propertyVal voMessage, 'message', 'TEST_BODY'
        yield return
    it 'should handle send-to-log notification (error)', ->
      co ->
        KEY = 'TEST_LOGGING_JUNCTION_MIXIN_001'
        TEST_BODY = 'TEST_BODY'
        class Test extends LeanRC
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class TestJunctionMediator extends LeanRC::Pipes::JunctionMediator
          @inheritProtected()
          @include LeanRC::LoggingJunctionMixin
          @module Test
        TestJunctionMediator.initialize()
        junction = LeanRC::Pipes::Junction.new()
        sinon.spy junction, 'sendMessage'
        mediator = TestJunctionMediator.new 'TEST_MEDIATOR', junction
        mediator.initializeNotifier KEY
        notification = LeanRC::Notification.new LeanRC::LogMessage.SEND_TO_LOG, TEST_BODY, LeanRC::LogMessage.LEVELS[LeanRC::LogMessage.ERROR]
        mediator.handleNotification notification
        [ vsOutputPipeName, voMessage ] = junction.sendMessage.args[0]
        assert.equal vsOutputPipeName, LeanRC::Pipes::PipeAwareModule.STDLOG
        assert.propertyVal voMessage, 'logLevel', LeanRC::LogMessage.ERROR
        assert.propertyVal voMessage, 'sender', KEY
        assert.propertyVal voMessage, 'message', 'TEST_BODY'
        yield return
    it 'should handle send-to-log notification (fatal)', ->
      co ->
        KEY = 'TEST_LOGGING_JUNCTION_MIXIN_001'
        TEST_BODY = 'TEST_BODY'
        class Test extends LeanRC
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class TestJunctionMediator extends LeanRC::Pipes::JunctionMediator
          @inheritProtected()
          @include LeanRC::LoggingJunctionMixin
          @module Test
        TestJunctionMediator.initialize()
        junction = LeanRC::Pipes::Junction.new()
        sinon.spy junction, 'sendMessage'
        mediator = TestJunctionMediator.new 'TEST_MEDIATOR', junction
        mediator.initializeNotifier KEY
        notification = LeanRC::Notification.new LeanRC::LogMessage.SEND_TO_LOG, TEST_BODY, LeanRC::LogMessage.LEVELS[LeanRC::LogMessage.FATAL]
        mediator.handleNotification notification
        [ vsOutputPipeName, voMessage ] = junction.sendMessage.args[0]
        assert.equal vsOutputPipeName, LeanRC::Pipes::PipeAwareModule.STDLOG
        assert.propertyVal voMessage, 'logLevel', LeanRC::LogMessage.FATAL
        assert.propertyVal voMessage, 'sender', KEY
        assert.propertyVal voMessage, 'message', 'TEST_BODY'
        yield return
    it 'should handle send-to-log notification (warn)', ->
      co ->
        KEY = 'TEST_LOGGING_JUNCTION_MIXIN_001'
        TEST_BODY = 'TEST_BODY'
        class Test extends LeanRC
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class TestJunctionMediator extends LeanRC::Pipes::JunctionMediator
          @inheritProtected()
          @include LeanRC::LoggingJunctionMixin
          @module Test
        TestJunctionMediator.initialize()
        junction = LeanRC::Pipes::Junction.new()
        sinon.spy junction, 'sendMessage'
        mediator = TestJunctionMediator.new 'TEST_MEDIATOR', junction
        mediator.initializeNotifier KEY
        notification = LeanRC::Notification.new LeanRC::LogMessage.SEND_TO_LOG, TEST_BODY, LeanRC::LogMessage.LEVELS[LeanRC::LogMessage.WARN]
        mediator.handleNotification notification
        [ vsOutputPipeName, voMessage ] = junction.sendMessage.args[0]
        assert.equal vsOutputPipeName, LeanRC::Pipes::PipeAwareModule.STDLOG
        assert.propertyVal voMessage, 'logLevel', LeanRC::LogMessage.WARN
        assert.propertyVal voMessage, 'sender', KEY
        assert.propertyVal voMessage, 'message', 'TEST_BODY'
        yield return
    it 'should handle set-to-log notification', ->
      co ->
        KEY = 'TEST_LOGGING_JUNCTION_MIXIN_002'
        TEST_LEVEL = LeanRC::LogMessage.NONE
        class Test extends LeanRC
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class TestJunctionMediator extends LeanRC::Pipes::JunctionMediator
          @inheritProtected()
          @include LeanRC::LoggingJunctionMixin
          @module Test
        TestJunctionMediator.initialize()
        junction = LeanRC::Pipes::Junction.new()
        sinon.spy junction, 'sendMessage'
        mediator = TestJunctionMediator.new 'TEST_MEDIATOR', junction
        mediator.initializeNotifier KEY
        notification = LeanRC::Notification.new LeanRC::LogFilterMessage.SET_LOG_LEVEL, TEST_LEVEL
        mediator.handleNotification notification
        [ vsOutputPipeName, voMessage ] = junction.sendMessage.args[0]
        assert.equal vsOutputPipeName, LeanRC::Pipes::PipeAwareModule.STDLOG
        assert.equal voMessage.getType(), LeanRC::Pipes::FilterControlMessage.SET_PARAMS
        assert.equal voMessage.logLevel, TEST_LEVEL
        [ vsOutputPipeName, voMessage ] = junction.sendMessage.args[1]
        assert.equal vsOutputPipeName, LeanRC::Pipes::PipeAwareModule.STDLOG
        assert.equal voMessage.logLevel, LeanRC::LogMessage.CHANGE
        assert.equal voMessage.sender, KEY
        assert.isDefined voMessage.time
        assert.equal voMessage.message, "
          Changed Log Level to: #{LeanRC::LogMessage.LEVELS[TEST_LEVEL]}
        "
        yield return
