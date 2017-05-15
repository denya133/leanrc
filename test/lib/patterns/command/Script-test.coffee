EventEmitter = require 'events'
{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils

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
        class Test extends LeanRC::Module
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
        class Test extends LeanRC::Module
          @inheritProtected()
          @root "#{__dirname}/config/root2"
        Test.initialize()
        class TestScript extends LeanRC::Script
          @inheritProtected()
          @module Test
          @do (args...) -> yield return args
          @public sendNotification: Function,
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
        assert.deepEqual options, [ LeanRC::JOB_RESULT, null, 'TEST_TYPE' ]
        yield return
    it 'should fail script', ->
      co ->
        KEY = 'TEST_SCRIPT_002'
        facade = LeanRC::Facade.getInstance KEY
        trigger = new EventEmitter
        class Test extends LeanRC::Module
          @inheritProtected()
          @root "#{__dirname}/config/root2"
        Test.initialize()
        class TestScript extends LeanRC::Script
          @inheritProtected()
          @module Test
          @do (args...) ->
            throw new Error 'TEST_ERROR'
            yield return
          @public sendNotification: Function,
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
        assert.instanceOf body, Error
        assert.equal type, 'TEST_TYPE'
        yield return
