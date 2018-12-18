EventEmitter = require 'events'
{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
{
  AnyT, NilT
  FuncG, MaybeG
  Utils: { co }
} = LeanRC::

describe 'Script', ->
  describe '.new', ->
    it 'should create new command', ->
      co ->
        command = LeanRC::Script.new()
        assert.instanceOf command, LeanRC::Script
        yield return
  describe '.do', ->
    it 'should add script body', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root2"
        Test.initialize()
        class TestScript extends LeanRC::Script
          @inheritProtected()
          @module Test
          @do (args...) -> yield return args
        TestScript.initialize()
        command = TestScript.new()
        [ data ] = yield command.body test: 'test'
        assert.deepEqual data, test: 'test'
        yield return
  describe '#execute', ->
    it 'should run script', ->
      co ->
        KEY = 'TEST_SCRIPT_001'
        facade = LeanRC::Facade.getInstance KEY
        trigger = new EventEmitter
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root2"
        Test.initialize()
        class TestScript extends LeanRC::Script
          @inheritProtected()
          @module Test
          @do (args...) -> yield return args
          @public sendNotification: FuncG([String, MaybeG(AnyT), MaybeG String], NilT),
            default: (args...) ->
              result = @super args...
              trigger.emit 'RUN_SCRIPT', args
              return result
        TestScript.initialize()
        command = TestScript.new()
        command.initializeNotifier KEY
        promise = LeanRC::Promise.new (resolve, reject) ->
          trigger.once 'RUN_SCRIPT', (options) -> resolve options
          return
        command.execute LeanRC::Notification.new 'TEST', { body: 'body' }, 'TEST_TYPE'
        options = yield promise
        assert.deepEqual options, [
          LeanRC::JOB_RESULT
          {result: [{body: 'body'}]}
          'TEST_TYPE'
        ]
        facade.remove()
        yield return
    it 'should fail script', ->
      co ->
        KEY = 'TEST_SCRIPT_002'
        facade = LeanRC::Facade.getInstance KEY
        trigger = new EventEmitter
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root2"
        Test.initialize()
        class TestScript extends LeanRC::Script
          @inheritProtected()
          @module Test
          @do (args...) ->
            throw new Error 'TEST_ERROR'
            yield return
          @public sendNotification: FuncG([String, MaybeG(AnyT), MaybeG String], NilT),
            default: (args...) ->
              result = @super args...
              trigger.emit 'RUN_SCRIPT', args
              return result
        TestScript.initialize()
        command = TestScript.new()
        command.initializeNotifier KEY
        promise = LeanRC::Promise.new (resolve, reject) ->
          trigger.once 'RUN_SCRIPT', (options) -> resolve options
          return
        command.execute LeanRC::Notification.new 'TEST', { body: 'body' }, 'TEST_TYPE'
        [ title, body, type ] = yield promise
        assert.equal title, LeanRC::JOB_RESULT
        assert.instanceOf body.error, Error
        assert.equal body.error.message, 'TEST_ERROR'
        assert.equal type, 'TEST_TYPE'
        facade.remove()
        yield return
