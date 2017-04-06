{ expect, assert } = require 'chai'
sinon = require 'sinon'
RC = require 'RC'
LeanRC = require.main.require 'lib'


describe 'Renderer', ->
  describe '.new', ->
    it 'should create renderer instance', ->
      expect ->
        renderer = LeanRC::Renderer.new 'TEST_RENDERER'
      .to.not.throw Error
  describe '#render', ->
    it 'should render the data', ->
      expect ->
        data = test: 'test1', data: 'data1'
        renderer = LeanRC::Renderer.new 'TEST_RENDERER'
        assert.equal renderer.render(data), JSON.stringify(data), 'Data not rendered'
      .to.not.throw Error
    it 'should render the data in customized renderer', ->
      expect ->
        data = firstName: 'John', lastName: 'Doe'
        class Test extends RC::Module
        class Test::TestRenderer extends LeanRC::Renderer
          @inheritProtected()
          @public render: Function,
            default: (aoData, aoOptions)->
              vhData = RC::Utils.extend {}, aoData, greeting: 'Hello'
              if aoOptions?.greeting?
                vhData.greeting = aoOptions.greeting
              "#{vhData.greeting}, #{vhData.firstName} #{vhData.lastName}!"
        Test::TestRenderer.initialize()
        renderer = Test::TestRenderer.new 'TEST_RENDERER'
        result = renderer.render data
        assert.equal result, 'Hello, John Doe!', 'Data without options not rendered'
        result = renderer.render data, greeting: 'Hola'
        assert.equal result, 'Hola, John Doe!', 'Data with options not rendered'
      .to.not.throw Error
