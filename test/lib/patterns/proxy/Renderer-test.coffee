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
        class Test extends RC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestRenderer extends LeanRC::Renderer
          @inheritProtected()
          @module Test
        Test::TestRenderer.initialize()
        renderer = Test::TestRenderer.new()
        assert.equal renderer.templatesDir, "#{__dirname}/templates"
      .to.not.throw Error
  describe '#templates', ->
    it 'should get templates from scripts', ->
      co ->
        class Test extends RC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestRenderer extends LeanRC::Renderer
          @inheritProtected()
          @module Test
        Test::TestRenderer.initialize()
        renderer = Test::TestRenderer.new()
        templates = yield renderer.templates
        assert.property templates, 'test'
        yield return
    it 'should run test template from script', ->
      co ->
        class Test extends RC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestRenderer extends LeanRC::Renderer
          @inheritProtected()
          @module Test
        Test::TestRenderer.initialize()
        renderer = Test::TestRenderer.new()
        templates = yield renderer.templates
        items = [
          id: 1, _key: 1, test: 'test1'
        ,
          id: 2, _key: 2, test: 'test2'
        ,
          id: 3, _key: 3, test: 'test3'
        ]
        output = templates.test 'TestRecord', 'find', items
        assert.property output, 'test_records'
        assert.sameDeepMembers output.test_records, [
          id: 1, test: 'test1'
        ,
          id: 2, test: 'test2'
        ,
          id: 3, test: 'test3'
        ]
        yield return
  describe '#render', ->
    it 'should render the data', ->
      co ->
        data = test: 'test1', data: 'data1'
        renderer = LeanRC::Renderer.new 'TEST_RENDERER'
        renderResult = yield renderer.render data
        assert.equal renderResult, JSON.stringify(data), 'Data not rendered'
        yield return
    it 'should render the data with template', ->
      co ->
        class Test extends RC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestRenderer extends LeanRC::Renderer
          @inheritProtected()
          @module Test
        Test::TestRenderer.initialize()
        data = id: 1, _key: 1, test: 'test1', data: 'data1'
        renderer = Test::TestRenderer.new 'TEST_RENDERER'
        renderResult = yield renderer.render data,
          path: 'test'
          resource: 'TestRecord'
          action: 'find'
        assert.deepEqual renderResult, JSON.stringify test_records: [
          id: 1, test: "test1", data: "data1"
        ]
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
