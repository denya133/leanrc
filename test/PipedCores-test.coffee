EventEmitter = require 'events'
{ expect, assert } = require 'chai'
sinon = require 'sinon'
# request = require 'request'
LeanRC = require.main.require 'lib'
CucumbersApp = require './integration/piped-cores/CucumbersModule/shell'
CucumbersSchema = require './integration/piped-cores/CucumbersModule/schema'
TomatosApp = require './integration/piped-cores/TomatosModule/shell'
TomatosSchema = require './integration/piped-cores/TomatosModule/schema'
{ co, request } = LeanRC::Utils


describe 'PipedCores', ->
  describe 'Create CucumbersSchema app instance', ->
    it 'should apply all migrations', ->
      co ->
        trigger = new EventEmitter
        waitForStop = -> Test::Promise.new (resolve) -> trigger.once 'STOPPED', resolve
        class Test extends CucumbersSchema
          @inheritProtected()
        Test.initialize()
        class TestCommand extends LeanRC::SimpleCommand
          @inheritProtected()
          @module Test
          @public execute: Function,
            default: ->
              trigger.emit 'STOPPED'
              return
        TestCommand.initialize()
        app = Test::SchemaApplication.new()
        app.facade.registerCommand Test::STOPPED_MIGRATE, Test::TestCommand
        cucumbersCollection = app.facade.retrieveProxy 'CucumbersCollection'
        migrationsCollection = app.facade.retrieveProxy Test::MIGRATIONS
        resque = app.facade.retrieveProxy Test::RESQUE
        for name in Test::MIGRATION_NAMES
          promise = waitForStop()
          app.facade.sendNotification Test::MIGRATE, until: name
          res = yield promise
          assert.isUndefined res
          assert.property migrationsCollection[Symbol.for '~collection'], name
          switch name
            when '20161006133500_create_default_queue_migration'
              assert.property resque[Symbol.for '~delayedQueues'], 'CucumbersSchema|>default'
            when '20161006133800_create_signals_queue_migration'
              assert.property resque[Symbol.for '~delayedQueues'], 'CucumbersSchema|>signals'
            when '20161006133900_create_delayed_jobs_queue_migration'
              assert.property resque[Symbol.for '~delayedQueues'], 'CucumbersSchema|>delayed_jobs'
            # when '20161006134300_create_cucumbers_migration'
            when '20170206165146_generate_defaults_in_cucumbers_migration'
              cucumbersHash = cucumbersCollection[Symbol.for '~collection']
              for id in [ 1 .. 5 ]
                assert.property cucumbersHash, String id
                assert.deepPropertyVal cucumbersHash, "#{id}.name", "#{id}-test"
                assert.deepPropertyVal cucumbersHash, "#{id}.description", "#{id}-test description"
        app.finish()
        yield return
    it 'should revert all migrations (using `until`)', ->
      co ->
        trigger = new EventEmitter
        waitForStop = -> Test::Promise.new (resolve) -> trigger.once 'STOPPED', resolve
        class Test extends CucumbersSchema
          @inheritProtected()
        Test.initialize()
        class TestCommand extends LeanRC::SimpleCommand
          @inheritProtected()
          @module Test
          @public execute: Function,
            default: ->
              trigger.emit 'STOPPED'
              return
        TestCommand.initialize()
        app = Test::SchemaApplication.new()
        app.facade.registerCommand Test::STOPPED_MIGRATE, Test::TestCommand
        app.facade.registerCommand Test::STOPPED_ROLLBACK, Test::TestCommand
        cucumbersCollection = app.facade.retrieveProxy 'CucumbersCollection'
        migrationsCollection = app.facade.retrieveProxy Test::MIGRATIONS
        resque = app.facade.retrieveProxy Test::RESQUE
        app.facade.sendNotification Test::MIGRATE
        promise = waitForStop()
        yield promise
        for name in Test::MIGRATION_NAMES by -1
          promise = waitForStop()
          app.facade.sendNotification Test::ROLLBACK,
            until: name
            steps: migrationsCollection[Symbol.for '~collection'].length
          res = yield promise
          assert.isUndefined res
          assert.notProperty migrationsCollection[Symbol.for '~collection'], name
          switch name
            when '20161006133500_create_default_queue_migration'
              assert.notProperty resque[Symbol.for '~delayedQueues'], 'CucumbersSchema|>default'
            when '20161006133800_create_signals_queue_migration'
              assert.notProperty resque[Symbol.for '~delayedQueues'], 'CucumbersSchema|>signals'
            when '20161006133900_create_delayed_jobs_queue_migration'
              assert.notProperty resque[Symbol.for '~delayedQueues'], 'CucumbersSchema|>delayed_jobs'
            # when '20161006134300_create_cucumbers_migration'
            when '20170206165146_generate_defaults_in_cucumbers_migration'
              cucumbersHash = cucumbersCollection[Symbol.for '~collection']
              for id in [ 1 .. 5 ]
                assert.notProperty cucumbersHash, String id
        app.finish()
        yield return
    it 'should revert all migrations (using `steps`)', ->
      co ->
        trigger = new EventEmitter
        waitForStop = -> Test::Promise.new (resolve) -> trigger.once 'STOPPED', resolve
        class Test extends CucumbersSchema
          @inheritProtected()
        Test.initialize()
        class TestCommand extends LeanRC::SimpleCommand
          @inheritProtected()
          @module Test
          @public execute: Function,
            default: ->
              trigger.emit 'STOPPED'
              return
        TestCommand.initialize()
        app = Test::SchemaApplication.new()
        app.facade.registerCommand Test::STOPPED_MIGRATE, Test::TestCommand
        app.facade.registerCommand Test::STOPPED_ROLLBACK, Test::TestCommand
        cucumbersCollection = app.facade.retrieveProxy 'CucumbersCollection'
        migrationsCollection = app.facade.retrieveProxy Test::MIGRATIONS
        resque = app.facade.retrieveProxy Test::RESQUE
        app.facade.sendNotification Test::MIGRATE
        promise = waitForStop()
        yield promise
        for name in Test::MIGRATION_NAMES by -1
          promise = waitForStop()
          app.facade.sendNotification Test::ROLLBACK, steps: 1
          res = yield promise
          assert.isUndefined res
          assert.notProperty migrationsCollection[Symbol.for '~collection'], name
          switch name
            when '20161006133500_create_default_queue_migration'
              assert.notProperty resque[Symbol.for '~delayedQueues'], 'CucumbersSchema|>default'
            when '20161006133800_create_signals_queue_migration'
              assert.notProperty resque[Symbol.for '~delayedQueues'], 'CucumbersSchema|>signals'
            when '20161006133900_create_delayed_jobs_queue_migration'
              assert.notProperty resque[Symbol.for '~delayedQueues'], 'CucumbersSchema|>delayed_jobs'
            # when '20161006134300_create_cucumbers_migration'
            when '20170206165146_generate_defaults_in_cucumbers_migration'
              cucumbersHash = cucumbersCollection[Symbol.for '~collection']
              for id in [ 1 .. 5 ]
                assert.notProperty cucumbersHash, String id
        app.finish()
        yield return
  describe 'Create TomatosSchema app instance', ->
    it 'should apply all migrations', ->
      co ->
        trigger = new EventEmitter
        waitForStop = -> Test::Promise.new (resolve) -> trigger.once 'STOPPED', resolve
        class Test extends TomatosSchema
          @inheritProtected()
        Test.initialize()
        class TestCommand extends LeanRC::SimpleCommand
          @inheritProtected()
          @module Test
          @public execute: Function,
            default: ->
              trigger.emit 'STOPPED'
              return
        TestCommand.initialize()
        app = Test::SchemaApplication.new()
        app.facade.registerCommand Test::STOPPED_MIGRATE, Test::TestCommand
        tomatosCollection = app.facade.retrieveProxy 'TomatosCollection'
        migrationsCollection = app.facade.retrieveProxy Test::MIGRATIONS
        resque = app.facade.retrieveProxy Test::RESQUE
        for name in Test::MIGRATION_NAMES
          promise = waitForStop()
          app.facade.sendNotification Test::MIGRATE, until: name
          res = yield promise
          assert.isUndefined res
          assert.property migrationsCollection[Symbol.for '~collection'], name
          switch name
            when '20161006133500_create_default_queue_migration'
              assert.property resque[Symbol.for '~delayedQueues'], 'TomatosSchema|>default'
            when '20161006133800_create_signals_queue_migration'
              assert.property resque[Symbol.for '~delayedQueues'], 'TomatosSchema|>signals'
            when '20161006133900_create_delayed_jobs_queue_migration'
              assert.property resque[Symbol.for '~delayedQueues'], 'TomatosSchema|>delayed_jobs'
            # when '20161006134300_create_tomatos_migration'
            when '20170206165146_generate_defaults_in_tomatos_migration'
              tomatosHash = tomatosCollection[Symbol.for '~collection']
              for id in [ 1 .. 5 ]
                assert.property tomatosHash, String id
                assert.deepPropertyVal tomatosHash, "#{id}.name", "#{id}-test"
                assert.deepPropertyVal tomatosHash, "#{id}.description", "#{id}-test description"
        app.finish()
        yield return
    it 'should revert all migrations (using `until`)', ->
      co ->
        trigger = new EventEmitter
        waitForStop = -> Test::Promise.new (resolve) -> trigger.once 'STOPPED', resolve
        class Test extends TomatosSchema
          @inheritProtected()
        Test.initialize()
        class TestCommand extends LeanRC::SimpleCommand
          @inheritProtected()
          @module Test
          @public execute: Function,
            default: ->
              trigger.emit 'STOPPED'
              return
        TestCommand.initialize()
        app = Test::SchemaApplication.new()
        app.facade.registerCommand Test::STOPPED_MIGRATE, Test::TestCommand
        app.facade.registerCommand Test::STOPPED_ROLLBACK, Test::TestCommand
        tomatosCollection = app.facade.retrieveProxy 'TomatosCollection'
        migrationsCollection = app.facade.retrieveProxy Test::MIGRATIONS
        resque = app.facade.retrieveProxy Test::RESQUE
        app.facade.sendNotification Test::MIGRATE
        promise = waitForStop()
        yield promise
        for name in Test::MIGRATION_NAMES by -1
          promise = waitForStop()
          app.facade.sendNotification Test::ROLLBACK,
            until: name
            steps: migrationsCollection[Symbol.for '~collection'].length
          res = yield promise
          assert.isUndefined res
          assert.notProperty migrationsCollection[Symbol.for '~collection'], name
          switch name
            when '20161006133500_create_default_queue_migration'
              assert.notProperty resque[Symbol.for '~delayedQueues'], 'TomatosSchema|>default'
            when '20161006133800_create_signals_queue_migration'
              assert.notProperty resque[Symbol.for '~delayedQueues'], 'TomatosSchema|>signals'
            when '20161006133900_create_delayed_jobs_queue_migration'
              assert.notProperty resque[Symbol.for '~delayedQueues'], 'TomatosSchema|>delayed_jobs'
            # when '20161006134300_create_tomatos_migration'
            when '20170206165146_generate_defaults_in_tomatos_migration'
              tomatosHash = tomatosCollection[Symbol.for '~collection']
              for id in [ 1 .. 5 ]
                assert.notProperty tomatosHash, String id
        app.finish()
        yield return
    it 'should revert all migrations (using `steps`)', ->
      co ->
        trigger = new EventEmitter
        waitForStop = -> Test::Promise.new (resolve) -> trigger.once 'STOPPED', resolve
        class Test extends TomatosSchema
          @inheritProtected()
        Test.initialize()
        class TestCommand extends LeanRC::SimpleCommand
          @inheritProtected()
          @module Test
          @public execute: Function,
            default: ->
              trigger.emit 'STOPPED'
              return
        TestCommand.initialize()
        app = Test::SchemaApplication.new()
        app.facade.registerCommand Test::STOPPED_MIGRATE, Test::TestCommand
        app.facade.registerCommand Test::STOPPED_ROLLBACK, Test::TestCommand
        tomatosCollection = app.facade.retrieveProxy 'TomatosCollection'
        migrationsCollection = app.facade.retrieveProxy Test::MIGRATIONS
        resque = app.facade.retrieveProxy Test::RESQUE
        app.facade.sendNotification Test::MIGRATE
        promise = waitForStop()
        yield promise
        for name in Test::MIGRATION_NAMES by -1
          promise = waitForStop()
          app.facade.sendNotification Test::ROLLBACK, steps: 1
          res = yield promise
          assert.isUndefined res
          assert.notProperty migrationsCollection[Symbol.for '~collection'], name
          switch name
            when '20161006133500_create_default_queue_migration'
              assert.notProperty resque[Symbol.for '~delayedQueues'], 'TomatosSchema|>default'
            when '20161006133800_create_signals_queue_migration'
              assert.notProperty resque[Symbol.for '~delayedQueues'], 'TomatosSchema|>signals'
            when '20161006133900_create_delayed_jobs_queue_migration'
              assert.notProperty resque[Symbol.for '~delayedQueues'], 'TomatosSchema|>delayed_jobs'
            # when '20161006134300_create_tomatos_migration'
            when '20170206165146_generate_defaults_in_tomatos_migration'
              tomatosHash = tomatosCollection[Symbol.for '~collection']
              for id in [ 1 .. 5 ]
                assert.notProperty tomatosHash, String id
        app.finish()
        yield return
  describe 'Create Cucumbers app instance', ->
    it 'should create new CucumbersApp', ->
      expect ->
        app = CucumbersApp::ShellApplication.new()
        app.finish()
      .to.not.throw Error
  describe 'Create Tomatos app instance', ->
    it 'should create new TomatosApp', ->
      expect ->
        app = TomatosApp::ShellApplication.new()
        app.finish()
      .to.not.throw Error
  describe 'Create Cucumbers app and test pipes', ->
    it 'should create new CucumbersApp and test pipes from shell to logger', ->
      expect ->
        { CHANGE, DEBUG } = CucumbersApp::Pipes::LogMessage
        { NAME } = CucumbersApp::ShellApplication
        { NORMAL } = CucumbersApp::Pipes::PipeMessage
        TEST_LOG_MESSAGE = 'TEST log message'
        app = CucumbersApp::ShellApplication.new()
        app.facade.sendNotification(CucumbersApp::LogMessage.SEND_TO_LOG, TEST_LOG_MESSAGE, CucumbersApp::LogMessage.LEVELS[CucumbersApp::LogMessage.DEBUG])

        facade = CucumbersApp::Facade.getInstance 'CucumbersLogger'

        logs = facade.retrieveProxy CucumbersApp::Application::LOGGER_PROXY
        assert.equal logs.messages[0].getHeader().logLevel, CHANGE
        assert.equal logs.messages[0].getHeader().sender, NAME
        assert.doesNotThrow -> Date.parse logs.messages[0].getHeader().time
        assert.equal logs.messages[0].getBody(), 'Changed Log Level to: DEBUG'
        assert.equal logs.messages[0].getType(), NORMAL
        assert.equal logs.messages[1].getHeader().logLevel, DEBUG
        assert.equal logs.messages[1].getHeader().sender, NAME
        assert.doesNotThrow -> Date.parse logs.messages[1].getHeader().time
        assert.equal logs.messages[1].getBody(), TEST_LOG_MESSAGE
        assert.equal logs.messages[1].getType(), NORMAL
        app.finish()
      .to.not.throw Error
  describe 'Create Tomatos app and test pipes', ->
    it 'should create new TomatosApp and test pipes from shell to logger', ->
      expect ->
        { CHANGE, DEBUG } = TomatosApp::Pipes::LogMessage
        { NAME } = TomatosApp::ShellApplication
        { NORMAL } = TomatosApp::Pipes::PipeMessage
        TEST_LOG_MESSAGE = 'TEST log message'
        app = TomatosApp::ShellApplication.new()
        app.facade.sendNotification(TomatosApp::LogMessage.SEND_TO_LOG, TEST_LOG_MESSAGE, TomatosApp::LogMessage.LEVELS[TomatosApp::LogMessage.DEBUG])

        facade = TomatosApp::Facade.getInstance 'TomatosLogger'

        logs = facade.retrieveProxy TomatosApp::Application::LOGGER_PROXY
        assert.equal logs.messages[0].getHeader().logLevel, CHANGE
        assert.equal logs.messages[0].getHeader().sender, NAME
        assert.doesNotThrow -> Date.parse logs.messages[0].getHeader().time
        assert.equal logs.messages[0].getBody(), 'Changed Log Level to: DEBUG'
        assert.equal logs.messages[0].getType(), NORMAL
        assert.equal logs.messages[1].getHeader().logLevel, DEBUG
        assert.equal logs.messages[1].getHeader().sender, NAME
        assert.doesNotThrow -> Date.parse logs.messages[1].getHeader().time
        assert.equal logs.messages[1].getBody(), TEST_LOG_MESSAGE
        assert.equal logs.messages[1].getType(), NORMAL
        app.finish()
      .to.not.throw Error
  describe 'Create Cucumbers app instance and send request', ->
    it 'should create new CucumbersApp and respond on request', ->
      co ->
        cucumbers = CucumbersApp::ShellApplication.new()
        res = yield request.get 'http://localhost:3002/0.1/cucumbers'
        { body: rawBody, status, message } = res
        assert.equal status, 200
        assert.equal message, 'OK'
        body = JSON.parse rawBody ? null
        assert.isTrue body?
        { meta, cucumbers: data } = body
        assert.deepEqual meta, pagination:
          total: 'not defined'
          limit: 'not defined'
          offset: 'not defined'
        assert.lengthOf data, 0
        # здесь можно проверить сколько объектов вернулось в {cucumbers} = res
        cucumbers.finish()
        yield return
  describe 'Create Tomatos app instance and send request', ->
    it 'should create new TomatosApp and respond on request', ->
      co ->
        tomatos = TomatosApp::ShellApplication.new()
        res = yield request.get 'http://localhost:3001/0.1/tomatos'
        { body: rawBody, status, message } = res
        assert.equal status, 200
        assert.equal message, 'OK'
        body = JSON.parse rawBody ? null
        assert.isTrue body?
        { meta, tomatos: data } = body
        assert.deepEqual meta, pagination:
          total: 'not defined'
          limit: 'not defined'
          offset: 'not defined'
        assert.lengthOf data, 0
        # здесь можно проверить сколько объектов вернулось в {tomatos} = res
        tomatos.finish()
        yield return
  describe 'Create Cucumbers app and test CRUD', ->
    it 'should create new CucumbersApp and send CRUD requests', ->
      co ->
        cucumbers = CucumbersApp::ShellApplication.new()
        res1 = yield request.post 'http://localhost:3002/0.1/cucumbers',
          body:
            cucumber:
              name: 'cucumber1'
              description: 'cucumber1 description'
        assert.propertyVal res1, 'status', 201
        assert.propertyVal res1, 'message', 'Created'
        body = JSON.parse res1.body ? null
        { cucumber: item } = body
        assert.propertyVal item, 'type', 'Cucumbers::CucumberRecord'
        assert.propertyVal item, 'name', 'cucumber1'
        assert.propertyVal item, 'description', 'cucumber1 description'
        assert.propertyVal item, 'isHidden', no
        assert.isUndefined item.deletedAt
        res2 = yield request.post 'http://localhost:3002/0.1/cucumbers',
          body:
            cucumber:
              name: 'cucumber2'
              description: 'cucumber2 description'
        assert.propertyVal res2, 'status', 201
        assert.propertyVal res2, 'message', 'Created'
        body = JSON.parse res2.body ? null
        { cucumber: item } = body
        assert.propertyVal item, 'type', 'Cucumbers::CucumberRecord'
        assert.propertyVal item, 'name', 'cucumber2'
        assert.propertyVal item, 'description', 'cucumber2 description'
        assert.propertyVal item, 'isHidden', no
        assert.isUndefined item.deletedAt
        res3 = yield request.post 'http://localhost:3002/0.1/cucumbers',
          body:
            cucumber:
              name: 'cucumber3'
              description: 'cucumber3 description'
        assert.propertyVal res3, 'status', 201
        assert.propertyVal res3, 'message', 'Created'
        body = JSON.parse res3.body ? null
        { cucumber: item } = body
        assert.propertyVal item, 'type', 'Cucumbers::CucumberRecord'
        assert.propertyVal item, 'name', 'cucumber3'
        assert.propertyVal item, 'description', 'cucumber3 description'
        assert.propertyVal item, 'isHidden', no
        assert.isUndefined item.deletedAt
        res4 = yield request.get 'http://localhost:3002/0.1/cucumbers'
        assert.propertyVal res4, 'status', 200
        assert.propertyVal res4, 'message', 'OK'
        body = JSON.parse res4.body ? null
        { cucumbers: items } = body
        assert.lengthOf items, 3
        for item, index in items
          assert.propertyVal item, 'type', 'Cucumbers::CucumberRecord'
          assert.propertyVal item, 'name', "cucumber#{index + 1}"
          assert.propertyVal item, 'description', "cucumber#{index + 1} description"
          assert.propertyVal item, 'isHidden', no
          assert.isNull item.deletedAt
        {cucumber:{id:cucumber2Id}} = JSON.parse res2.body
        res5 = yield request.put "http://localhost:3002/0.1/cucumbers/#{cucumber2Id}",
          body:
            cucumber:
              name: 'cucumber2'
              description: 'cucumber2 long description'
        assert.propertyVal res5, 'status', 200
        assert.propertyVal res5, 'message', 'OK'
        body = JSON.parse res5.body ? null
        { cucumber: item } = body
        assert.propertyVal item, 'type', 'Cucumbers::CucumberRecord'
        assert.propertyVal item, 'name', 'cucumber2'
        assert.propertyVal item, 'description', 'cucumber2 long description'
        assert.propertyVal item, 'isHidden', no
        assert.isNull item.deletedAt
        res6 = yield request.delete "http://localhost:3002/0.1/cucumbers/#{cucumber2Id}"
        assert.propertyVal res6, 'status', 200
        assert.propertyVal res6, 'message', 'OK'
        body = JSON.parse res6.body ? null
        { cucumber: item } = body
        assert.propertyVal item, 'type', 'Cucumbers::CucumberRecord'
        assert.propertyVal item, 'name', 'cucumber2'
        assert.propertyVal item, 'description', 'cucumber2 long description'
        assert.propertyVal item, 'isHidden', yes
        assert.isNotNull item.deletedAt
        cucumbers.finish()
        yield return
  describe 'Create Tomatos app and test CRUD', ->
    it 'should create new TomatosApp and send CRUD requests', ->
      co ->
        tomatos = TomatosApp::ShellApplication.new()
        res1 = yield request.post 'http://localhost:3001/0.1/tomatos',
          body:
            tomato:
              name: 'tomato1'
              description: 'tomato1 description'
        assert.propertyVal res1, 'status', 201
        assert.propertyVal res1, 'message', 'Created'
        body = JSON.parse res1.body ? null
        { tomato: item } = body
        assert.propertyVal item, 'type', 'Tomatos::TomatoRecord'
        assert.propertyVal item, 'name', 'tomato1'
        assert.propertyVal item, 'description', 'tomato1 description'
        assert.propertyVal item, 'isHidden', no
        assert.isUndefined item.deletedAt
        res2 = yield request.post 'http://localhost:3001/0.1/tomatos',
          body:
            tomato:
              name: 'tomato2'
              description: 'tomato2 description'
        assert.propertyVal res2, 'status', 201
        assert.propertyVal res2, 'message', 'Created'
        body = JSON.parse res2.body ? null
        { tomato: item } = body
        assert.propertyVal item, 'type', 'Tomatos::TomatoRecord'
        assert.propertyVal item, 'name', 'tomato2'
        assert.propertyVal item, 'description', 'tomato2 description'
        assert.propertyVal item, 'isHidden', no
        assert.isUndefined item.deletedAt
        res3 = yield request.post 'http://localhost:3001/0.1/tomatos',
          body:
            tomato:
              name: 'tomato3'
              description: 'tomato3 description'
        assert.propertyVal res3, 'status', 201
        assert.propertyVal res3, 'message', 'Created'
        body = JSON.parse res3.body ? null
        { tomato: item } = body
        assert.propertyVal item, 'type', 'Tomatos::TomatoRecord'
        assert.propertyVal item, 'name', 'tomato3'
        assert.propertyVal item, 'description', 'tomato3 description'
        assert.propertyVal item, 'isHidden', no
        assert.isUndefined item.deletedAt
        res4 = yield request.get 'http://localhost:3001/0.1/tomatos'
        assert.propertyVal res4, 'status', 200
        assert.propertyVal res4, 'message', 'OK'
        body = JSON.parse res4.body ? null
        { tomatos: items } = body
        assert.lengthOf items, 3
        for item, index in items
          assert.propertyVal item, 'type', 'Tomatos::TomatoRecord'
          assert.propertyVal item, 'name', "tomato#{index + 1}"
          assert.propertyVal item, 'description', "tomato#{index + 1} description"
          assert.propertyVal item, 'isHidden', no
          assert.isNull item.deletedAt
        {tomato:{id:tomato2Id}} = JSON.parse res2.body
        res5 = yield request.put "http://localhost:3001/0.1/tomatos/#{tomato2Id}",
          body:
            tomato:
              name: 'tomato2'
              description: 'tomato2 long description'
        assert.propertyVal res5, 'status', 200
        assert.propertyVal res5, 'message', 'OK'
        body = JSON.parse res5.body ? null
        { tomato: item } = body
        assert.propertyVal item, 'type', 'Tomatos::TomatoRecord'
        assert.propertyVal item, 'name', 'tomato2'
        assert.propertyVal item, 'description', 'tomato2 long description'
        assert.propertyVal item, 'isHidden', no
        assert.isNull item.deletedAt
        res6 = yield request.delete "http://localhost:3001/0.1/tomatos/#{tomato2Id}"
        assert.propertyVal res6, 'status', 200
        assert.propertyVal res6, 'message', 'OK'
        body = JSON.parse res6.body ? null
        { tomato: item } = body
        assert.propertyVal item, 'type', 'Tomatos::TomatoRecord'
        assert.propertyVal item, 'name', 'tomato2'
        assert.propertyVal item, 'description', 'tomato2 long description'
        assert.propertyVal item, 'isHidden', yes
        assert.isNotNull item.deletedAt
        tomatos.finish()
  describe 'Create Cucumbers app and Tomatos app and test its interaction', ->
    it 'should create two apps and get cucumber from tomato', ->
      co ->
        cucumbers = CucumbersApp::ShellApplication.new()
        tomatos = TomatosApp::ShellApplication.new()
        res1 = yield request.post 'http://localhost:3002/0.1/cucumbers',
          body:
            cucumber:
              name: 'cucumber1'
              description: 'cucumber1 description'
        assert.propertyVal res1, 'status', 201
        assert.propertyVal res1, 'message', 'Created'
        body = JSON.parse res1.body ? null
        { cucumber: item } = body
        assert.propertyVal item, 'type', 'Cucumbers::CucumberRecord'
        assert.propertyVal item, 'name', 'cucumber1'
        assert.propertyVal item, 'description', 'cucumber1 description'
        assert.propertyVal item, 'isHidden', no
        assert.isUndefined item.deletedAt
        res2 = yield request.post 'http://localhost:3002/0.1/cucumbers',
          body:
            cucumber:
              name: 'cucumber2'
              description: 'cucumber2 description'
        assert.propertyVal res2, 'status', 201
        assert.propertyVal res2, 'message', 'Created'
        body = JSON.parse res2.body ? null
        { cucumber: item } = body
        assert.propertyVal item, 'type', 'Cucumbers::CucumberRecord'
        assert.propertyVal item, 'name', 'cucumber2'
        assert.propertyVal item, 'description', 'cucumber2 description'
        assert.propertyVal item, 'isHidden', no
        assert.isUndefined item.deletedAt
        res3 = yield request.post 'http://localhost:3002/0.1/cucumbers',
          body:
            cucumber:
              name: 'cucumber3'
              description: 'cucumber3 description'
        assert.propertyVal res3, 'status', 201
        assert.propertyVal res3, 'message', 'Created'
        body = JSON.parse res3.body ? null
        { cucumber: item } = body
        assert.propertyVal item, 'type', 'Cucumbers::CucumberRecord'
        assert.propertyVal item, 'name', 'cucumber3'
        assert.propertyVal item, 'description', 'cucumber3 description'
        assert.propertyVal item, 'isHidden', no
        assert.isUndefined item.deletedAt
        res4 = yield request.get 'http://localhost:3002/0.1/cucumbers'
        assert.propertyVal res4, 'status', 200
        assert.propertyVal res4, 'message', 'OK'
        body = JSON.parse res4.body ? null
        { cucumbers: items } = body
        assert.lengthOf items, 3
        for item, index in items
          assert.propertyVal item, 'type', 'Cucumbers::CucumberRecord'
          assert.propertyVal item, 'name', "cucumber#{index + 1}"
          assert.propertyVal item, 'description', "cucumber#{index + 1} description"
          assert.propertyVal item, 'isHidden', no
          assert.isNull item.deletedAt
        res5 = yield request.get 'http://localhost:3001/0.1/cucumbers'
        assert.propertyVal res5, 'status', 200
        assert.propertyVal res5, 'message', 'OK'
        items = JSON.parse res5.body ? null
        assert.lengthOf items, 3
        for item, index in items
          assert.propertyVal item, 'type', 'Cucumbers::CucumberRecord'
          assert.propertyVal item, 'name', "cucumber#{index + 1}"
          assert.propertyVal item, 'description', "cucumber#{index + 1} description"
          assert.propertyVal item, 'isHidden', no
          assert.isNull item.deletedAt

        tomatos.finish()
        cucumbers.finish()
