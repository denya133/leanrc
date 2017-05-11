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
  describe 'Create Cucumbers app instance and send request', ->
    it 'should create new CucumbersApp and respond on request', ->
      co ->
        try
          cucumbers = CucumbersApp::ShellApplication.new()
          res = yield request.get 'http://localhost:3002/0.1/cucumbers'
          console.log '?????', res
        catch err
          console.error '????? ERROR', err
        cucumbers.finish()
