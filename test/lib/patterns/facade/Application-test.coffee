{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils

describe 'Application', ->
  describe '.new', ->
    it 'should create new Application instance', ->
      co ->
        KEY = 'TEST_APPLICATION_001'
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class ApplicationFacade extends LeanRC::Facade
          @inheritProtected()
          @module Test
          vpbIsInitialized = @private isInitialized: Boolean,
            default: no
          cphInstanceMap  = @protected @static instanceMap: Object,
            default: {}
          @public startup: Function,
            default: (args...) ->
              @super args...
              unless @[vpbIsInitialized]
                @[vpbIsInitialized] = yes
          @public finish: Function,
            default: (args...) -> @super args...
          @public @static getInstance: Function,
            default: (asKey)->
              vhInstanceMap = LeanRC::Facade[cphInstanceMap]
              unless vhInstanceMap[asKey]?
                vhInstanceMap[asKey] = Test::ApplicationFacade.new asKey
              vhInstanceMap[asKey]
        ApplicationFacade.initialize()
        class Application extends LeanRC::Application
          @inheritProtected()
          @module Test
          @public @static NAME: String,
            default: 'TestApplication'
        Application.initialize()
        application = Application.new()
        assert.instanceOf application, Application
        yield return
