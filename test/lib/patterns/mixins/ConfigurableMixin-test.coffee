{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
RC = require 'RC'
LeanRC = require.main.require 'lib'
{ co } = RC::Utils


describe 'ConfigurableMixin', ->
  describe '#configs', ->
    it 'should create configuration instance', ->
      co ->
        KEY = 'TEST_CONFIG_MIXIN_001'
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
        class Test::Test extends LeanRC::Proxy
          @inheritProtected()
          @include LeanRC::ConfigurableMixin
          @module Test
        Test::Test.initialize()
        facade.registerProxy object = Test::Test.new 'TEST'
        assert.deepPropertyVal object, 'configs.test1', 'default'
        assert.deepPropertyVal object, 'configs.test2', 42
        assert.deepPropertyVal object, 'configs.test3', yes
        assert.deepPropertyVal object, 'configs.test4', 'test'
        facade.remove()
        yield return
