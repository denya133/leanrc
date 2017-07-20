{ expect, assert } = require 'chai'
sinon = require 'sinon'
RC = require 'RC'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils


describe 'Renderer', ->
  describe '.new', ->
    it 'should create renderer instance', ->
      expect ->
        renderer = LeanRC::Renderer.new 'TEST_RENDERER'
      .to.not.throw Error
  describe '#templatesDir', ->
    it 'should get templates directory', ->
      expect ->
        KEY = 'TEST_RENDERER_001'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends RC::Module
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Test::Configuration extends LeanRC::Configuration
          @inheritProtected()
          @module Test
        Test::Configuration.initialize()
        facade.registerProxy Test::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        class Test::TestRenderer extends LeanRC::Renderer
          @inheritProtected()
          @module Test
        Test::TestRenderer.initialize()
        renderer = Test::TestRenderer.new()
        facade.registerProxy renderer
        assert.equal renderer.templatesDir, "#{__dirname}/config/root/../lib/templates"
        facade.remove()
      .to.not.throw Error
  describe '#templates', ->
    it 'should get templates from scripts', ->
      co ->
        KEY = 'TEST_RENDERER_002'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends RC::Module
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Test::Configuration extends LeanRC::Configuration
          @inheritProtected()
          @module Test
        Test::Configuration.initialize()
        facade.registerProxy Test::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        class Test::TestRenderer extends LeanRC::Renderer
          @inheritProtected()
          @module Test
        Test::TestRenderer.initialize()
        renderer = Test::TestRenderer.new()
        facade.registerProxy renderer
        templates = yield renderer.templates
        assert.property templates, 'TestRecord/find'
        facade.remove()
        yield return
    it 'should run test template from script', ->
      co ->
        KEY = 'TEST_RENDERER_003'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends RC::Module
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Test::Configuration extends LeanRC::Configuration
          @inheritProtected()
          @module Test
        Test::Configuration.initialize()
        class Test::TestResource extends LeanRC::Resource
          @inheritProtected()
          @include LeanRC::QueryableResourceMixin
          @module Test
          @public entityName: String, { default: 'TestRecord' }
        Test::TestResource.initialize()
        facade.registerProxy Test::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        class Test::TestRenderer extends LeanRC::Renderer
          @inheritProtected()
          @module Test
        Test::TestRenderer.initialize()
        renderer = Test::TestRenderer.new()
        facade.registerProxy renderer
        templates = yield renderer.templates
        items = [
          id: 1, test: 'test1'
        ,
          id: 2, test: 'test2'
        ,
          id: 3, test: 'test3'
        ]
        resource = Test::TestResource.new()
        resource.initializeNotifier KEY
        output = yield templates['TestRecord/find'].call resource, 'TestRecord', 'find', items
        assert.property output, 'test_records'
        assert.sameDeepMembers output.test_records, [
          id: 1, test: 'test1'
        ,
          id: 2, test: 'test2'
        ,
          id: 3, test: 'test3'
        ]
        facade.remove()
        yield return
  describe '#render', ->
    it 'should render the data', ->
      co ->
        KEY = 'TEST_RENDERER_004'
        facade = LeanRC::Facade.getInstance KEY
        data = test: 'test1', data: 'data1'
        renderer = LeanRC::Renderer.new 'TEST_RENDERER'
        facade.registerProxy renderer
        renderResult = yield renderer.render {}, data, {}, {}
        assert.equal renderResult, data, 'Data not rendered'
        facade.remove()
        yield return
    it 'should render the data with template', ->
      co ->
        KEY = 'TEST_RENDERER_005'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends RC::Module
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Test::Configuration extends LeanRC::Configuration
          @inheritProtected()
          @module Test
        Test::Configuration.initialize()
        class Test::TestResource extends LeanRC::Resource
          @inheritProtected()
          @include LeanRC::QueryableResourceMixin
          @module Test
          @public entityName: String, { default: 'TestRecord' }
        Test::TestResource.initialize()
        facade.registerProxy Test::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        class Test::TestRenderer extends LeanRC::Renderer
          @inheritProtected()
          @module Test
        Test::TestRenderer.initialize()
        data = [id: 1, test: 'test1', data: 'data1']
        renderer = Test::TestRenderer.new 'TEST_RENDERER'
        facade.registerProxy renderer
        resource = Test::TestResource.new()
        resource.initializeNotifier KEY
        renderResult = yield renderer.render {}, data, resource,
          path: 'test'
          resource: 'TestRecord/'
          action: 'find'
        assert.deepEqual renderResult, test_records: data
        facade.remove()
        yield return
    it 'should render the data in customized renderer', ->
      co ->
        data = firstName: 'John', lastName: 'Doe'
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRenderer extends LeanRC::Renderer
          @inheritProtected()
          @module Test
          @public render: Function,
            default: (aoData, aoOptions)->
              vhData = RC::Utils.extend {}, aoData, greeting: 'Hello'
              if aoOptions?.greeting?
                vhData.greeting = aoOptions.greeting
              "#{vhData.greeting}, #{vhData.firstName} #{vhData.lastName}!"
        Test::TestRenderer.initialize()
        renderer = Test::TestRenderer.new 'TEST_RENDERER'
        result = yield renderer.render data
        assert.equal result, 'Hello, John Doe!', 'Data without options not rendered'
        result = yield renderer.render data, greeting: 'Hola'
        assert.equal result, 'Hola, John Doe!', 'Data with options not rendered'
        yield return
