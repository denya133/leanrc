{ expect, assert } = require 'chai'
sinon = require 'sinon'
request = require 'request'
LeanRC = require.main.require 'lib'
CucumbersApp = require './integration/piped-cores/CucumbersModule/shell'
TomatosApp = require './integration/piped-cores/TomatosModule/shell'


describe 'PipedCores', ->
  ###
  describe 'Create Cucumbers app instance', ->
    it 'should get new or existing instance of Facade', ->
      # expect ->
        app = CucumbersApp::ShellApplication.new()
        app.finish()
      # .to.not.throw Error
  describe 'Create Tomatos app instance', ->
    it 'should get new or existing instance of Facade', ->
      # expect ->
        app = TomatosApp::ShellApplication.new()
        app.finish()
      # .to.not.throw Error
  ###
