EventEmitter = require 'events'
{ expect, assert } = require 'chai'
sinon = require 'sinon'
# request = require 'request'
LeanRC = require.main.require 'lib'
CucumbersApp = require './integration/piped-cores/CucumbersModule/shell'
CucumbersSchema = require './integration/piped-cores/CucumbersModule/schema'
TomatosApp = require './integration/piped-cores/TomatosModule/shell'
{ co, request } = LeanRC::Utils


describe 'PipedCores', ->
  describe 'Create CucumbersSchema app instance', ->
    it 'should apply all migrations', ->
      co ->
        trigger = new EventEmitter
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
          promise = Test::Promise.new (resolve) ->
            trigger.once 'STOPPED', resolve
          app.facade.sendNotification Test::MIGRATE, until: name
          res = yield promise
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
              assert.property cucumbersCollection[Symbol.for '~collection'], '1'
        yield return
  describe 'Create CucumbersSchema app and ...', ->
    it 'должно выполнить все миграции в обратном направлении', ->
      throw new Error 'not implemented'
  describe 'Create TomatosSchema app and ...', ->
    it 'должно выполнить все миграции в прямом направлении', ->
      throw new Error 'not implemented'
  describe 'Create TomatosSchema app and ...', ->
    it 'должно выполнить все миграции в обратном направлении', ->
      throw new Error 'not implemented'
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
