{ expect, assert } = require 'chai'
sinon = require 'sinon'
# request = require 'request'
LeanRC = require.main.require 'lib'
CucumbersApp = require './integration/piped-cores/CucumbersModule/shell'
TomatosApp = require './integration/piped-cores/TomatosModule/shell'
{ co, request } = LeanRC::Utils


describe 'PipedCores', ->
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
