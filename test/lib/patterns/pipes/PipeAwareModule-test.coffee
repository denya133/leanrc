{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
Facade = LeanRC::Facade
PipeAwareModule = LeanRC::PipeAwareModule

describe 'PipeAwareModule', ->
  describe '.new', ->
    it 'should create new PipeAwareModule instance', ->
      expect ->
        facade = Facade.getInstance 'TEST_PIPE_AWARE_1'
        pipeAwareModule = PipeAwareModule.new facade
        assert.equal pipeAwareModule.facade, facade, 'Facade is incorrect'
      .to.not.throw Error
