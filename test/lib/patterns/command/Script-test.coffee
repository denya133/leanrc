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
    ###
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
          @public @async body: Function,
            default: (options) ->
              result = @super options
              trigger.emit 'RUN_SCRIPT', options
              return result
        TestScript.initialize()
        command = TestScript.new()
        command.initializeNotifier KEY
        promise = LeanRC::Promise.new (resolve, reject) ->
          trigger.once 'RUN_SCRIPT', (options) -> resolve options
          return
        command.execute LeanRC::Notification.new 'TEST', { body: 'body' }, 'TEST_TYPE'
        options = yield promise
        console.log '00000000000', options
        # assert.deepEqual options, until: untilName
        yield return
    ###
