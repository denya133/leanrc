{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
RC = require 'RC'
LeanRC = require.main.require 'lib'
{ co } = RC::Utils


describe 'Configuration', ->
  describe '.new', ->
    it 'should create configuration instance', ->
      co ->
        class Test extends RC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        configuration = LeanRC::Configuration.new()
        yield return
