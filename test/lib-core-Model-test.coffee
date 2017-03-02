{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require '../lib'
Model = LeanRC::Model

describe 'Model', ->
  describe '.getInstance', ->
    it 'should get new or existing instance of Model', ->
      expect ->
        model = Model.getInstance 'TEST1'
        assert model instanceof Model, 'The `model` is not an instance of Model'
      .to.not.throw Error
  describe '.removeModel', ->
    it 'should get new instance of Model, remove it and get new one', ->
      expect ->
        model = Model.getInstance 'TEST2'
        oldModel = Model.getInstance 'TEST2'
        assert model is oldModel, 'Model is not saved'
        Model.removeModel 'TEST2'
        newModel = Model.getInstance 'TEST2'
        assert model isnt newModel, 'Model instance didn\'t renewed'
      .to.not.throw Error
