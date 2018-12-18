EventEmitter = require 'events'
{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils

describe 'DelayedJobScript', ->
  describe '.new', ->
    it 'should create new command', ->
      co ->
        command = LeanRC::DelayedJobScript.new()
        assert.instanceOf command, LeanRC::DelayedJobScript
        yield return
  describe '#body', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should run delayed job script (class, sync)', ->
      co ->
        KEY = 'TEST_DELAYED_JOB_SCRIPT_001'
        facade = LeanRC::Facade.getInstance KEY
        trigger = new EventEmitter
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root2"
          @initialize()
        class TestScript extends LeanRC::DelayedJobScript
          @inheritProtected()
          @module Test
          @initialize()
        class TestClass extends LeanRC::CoreObject
          @inheritProtected()
          @module Test
          @public @static test: Function,
            default: (args...) ->
              trigger.emit 'RUN_SCRIPT', args
              return
          @initialize()
        class ApplicationMediator extends LeanRC::Mediator
          @inheritProtected()
          @module Test
          @initialize()
        class TestApplication extends LeanRC::CoreObject
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerMediator ApplicationMediator.new LeanRC::APPLICATION_MEDIATOR, TestApplication.new()
        command = TestScript.new()
        command.initializeNotifier KEY
        promise = LeanRC::Promise.new (resolve, reject) ->
          trigger.once 'RUN_SCRIPT', (options) -> resolve options
          return
        body =
          moduleName: 'Test'
          replica: yield TestClass.constructor.replicateObject TestClass
          methodName: 'test'
          args: [ 'ARG_1', 'ARG_2', 'ARG_3' ]
        command.execute LeanRC::Notification.new 'TEST', body, 'TEST_TYPE'
        data = yield promise
        assert.deepEqual data, [ 'ARG_1', 'ARG_2', 'ARG_3' ]
        yield return
    it 'should run delayed job script (instance, sync)', ->
      co ->
        KEY = 'TEST_DELAYED_JOB_SCRIPT_002'
        facade = LeanRC::Facade.getInstance KEY
        trigger = new EventEmitter
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root2"
          @initialize()
        class TestScript extends LeanRC::DelayedJobScript
          @inheritProtected()
          @module Test
          @initialize()
        class TestClass extends LeanRC::CoreObject
          @inheritProtected()
          @module Test
          @public test: Function,
            default: (args...) ->
              trigger.emit 'RUN_SCRIPT', args
              return
          @initialize()
        class ApplicationMediator extends LeanRC::Mediator
          @inheritProtected()
          @module Test
          @initialize()
        class TestApplication extends LeanRC::CoreObject
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerMediator ApplicationMediator.new LeanRC::APPLICATION_MEDIATOR, TestApplication.new()
        command = TestScript.new()
        command.initializeNotifier KEY
        promise = LeanRC::Promise.new (resolve, reject) ->
          trigger.once 'RUN_SCRIPT', (options) -> resolve options
          return
        body =
          moduleName: 'Test'
          replica: yield TestClass.replicateObject TestClass.new()
          methodName: 'test'
          args: [ 'ARG_1', 'ARG_2', 'ARG_3' ]
        command.execute LeanRC::Notification.new 'TEST', body, 'TEST_TYPE'
        data = yield promise
        assert.deepEqual data, [ 'ARG_1', 'ARG_2', 'ARG_3' ]
        yield return
    it 'should run delayed job script (class, async)', ->
      co ->
        KEY = 'TEST_DELAYED_JOB_SCRIPT_003'
        facade = LeanRC::Facade.getInstance KEY
        trigger = new EventEmitter
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root2"
          @initialize()
        class TestScript extends LeanRC::DelayedJobScript
          @inheritProtected()
          @module Test
          @initialize()
        class TestClass extends LeanRC::CoreObject
          @inheritProtected()
          @module Test
          @public @async @static test: Function,
            default: (args...) ->
              trigger.emit 'RUN_SCRIPT', args
              yield return
          @initialize()
        class ApplicationMediator extends LeanRC::Mediator
          @inheritProtected()
          @module Test
          @initialize()
        class TestApplication extends LeanRC::CoreObject
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerMediator ApplicationMediator.new LeanRC::APPLICATION_MEDIATOR, TestApplication.new()
        command = TestScript.new()
        command.initializeNotifier KEY
        promise = LeanRC::Promise.new (resolve, reject) ->
          trigger.once 'RUN_SCRIPT', (options) -> resolve options
          return
        body =
          moduleName: 'Test'
          replica: yield TestClass.constructor.replicateObject TestClass
          methodName: 'test'
          args: [ 'ARG_1', 'ARG_2', 'ARG_3' ]
        command.execute LeanRC::Notification.new 'TEST', body, 'TEST_TYPE'
        data = yield promise
        assert.deepEqual data, [ 'ARG_1', 'ARG_2', 'ARG_3' ]
        yield return
    it 'should run delayed job script (instance, async)', ->
      co ->
        KEY = 'TEST_DELAYED_JOB_SCRIPT_004'
        facade = LeanRC::Facade.getInstance KEY
        trigger = new EventEmitter
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root2"
          @initialize()
        class TestScript extends LeanRC::DelayedJobScript
          @inheritProtected()
          @module Test
          @initialize()
        class TestClass extends LeanRC::CoreObject
          @inheritProtected()
          @module Test
          @public @async test: Function,
            default: (args...) ->
              trigger.emit 'RUN_SCRIPT', args
              yield return
          @initialize()
        class ApplicationMediator extends LeanRC::Mediator
          @inheritProtected()
          @module Test
          @initialize()
        class TestApplication extends LeanRC::CoreObject
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerMediator ApplicationMediator.new LeanRC::APPLICATION_MEDIATOR, TestApplication.new()
        command = TestScript.new()
        command.initializeNotifier KEY
        promise = LeanRC::Promise.new (resolve, reject) ->
          trigger.once 'RUN_SCRIPT', (options) -> resolve options
          return
        body =
          moduleName: 'Test'
          replica: yield TestClass.replicateObject TestClass.new()
          methodName: 'test'
          args: [ 'ARG_1', 'ARG_2', 'ARG_3' ]
        command.execute LeanRC::Notification.new 'TEST', body, 'TEST_TYPE'
        data = yield promise
        assert.deepEqual data, [ 'ARG_1', 'ARG_2', 'ARG_3' ]
        yield return
