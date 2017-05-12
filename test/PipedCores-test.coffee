{ expect, assert } = require 'chai'
sinon = require 'sinon'
# request = require 'request'
LeanRC = require.main.require 'lib'
CucumbersApp = require './integration/piped-cores/CucumbersModule/shell'
TomatosApp = require './integration/piped-cores/TomatosModule/shell'
{ co, request } = LeanRC::Utils


describe 'PipedCores', ->
  describe 'Create CucumbersSchema app and ...', ->
    it 'должно выполнить все миграции в прямом направлении', ->
      throw new Error 'not implemented'
  describe 'Create CucumbersSchema app and ...', ->
    it 'должно выполнить все миграции в обратном направлении', ->
      throw new Error 'not implemented'
  describe 'Create TomatosSchema app and ...', ->
    it 'должно выполнить все миграции в прямом направлении', ->
      throw new Error 'not implemented'
  describe 'Create TomatosSchema app and ...', ->
    it 'должно выполнить все миграции в обратном направлении', ->
      throw new Error 'not implemented'
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
  describe 'Create Cucumbers app and ...', ->
    it 'нужно проверить что логи из shell и из main попадают в логера', ->
      # expect ->
        app = CucumbersApp::ShellApplication.new()
        app.facade.sendNotification(CucumbersApp::LogMessage.SEND_TO_LOG, "TEST log message", CucumbersApp::LogMessage.LEVELS[CucumbersApp::LogMessage.DEBUG])

        facade = CucumbersApp::Facade.getInstance 'CucumbersLogger'

        logs = facade.retrieveProxy CucumbersApp::Application::LOGGER_PROXY
        console.log 'Logs', logs.messages, logs.messages.map (m)-> [m.getHeader(), m.getBody()]
        app.finish()
      # .to.not.throw Error
  describe 'Create Tomatos app and ...', ->
    it 'нужно проверить что логи из shell и из main попадают в логера', ->
      # expect ->
        app = TomatosApp::ShellApplication.new()
        app.facade.sendNotification(TomatosApp::LogMessage.SEND_TO_LOG, "TEST log message", TomatosApp::LogMessage.LEVELS[TomatosApp::LogMessage.DEBUG])

        facade = TomatosApp::Facade.getInstance 'TomatosLogger'

        logs = facade.retrieveProxy TomatosApp::Application::LOGGER_PROXY
        console.log 'Logs', logs.messages, logs.messages.map (m)-> [m.getHeader(), m.getBody()]
        app.finish()
      # .to.not.throw Error
  describe 'Create Cucumbers app instance and send request', ->
    it 'should create new CucumbersApp and respond on request', ->
      co ->
        try
          cucumbers = CucumbersApp::ShellApplication.new()
          res = yield request.get 'http://localhost:3002/0.1/cucumbers'
          console.log '?????', res
          # здесь можно проверить сколько объектов вернулось в {cucumbers} = res
        catch err
          console.error '????? ERROR', err
        cucumbers.finish()
  describe 'Create Tomatos app instance and send request', ->
    it 'should create new TomatosApp and respond on request', ->
      co ->
        try
          tomatos = TomatosApp::ShellApplication.new()
          res = yield request.get 'http://localhost:3001/0.1/tomatos'
          console.log '?????', res
          # здесь можно проверить сколько объектов вернулось в {tomatos} = res
        catch err
          console.error '????? ERROR', err
        tomatos.finish()
  describe 'Create Cucumbers app and ...', ->
    it 'должно послать запрос на создание огурца, а потом запрос на получение этого огурца, потом на редактирование этого огурца, потом на удаление этого огурца - тестируем CRUD', ->
      throw new Error 'not implemented'
  describe 'Create Tomatos app and ...', ->
    it 'должно послать запрос на создание помидора, а потом запрос на получение этого помидора, потом на редактирование этого помидора, потом на удаление этого помидора - тестируем CRUD', ->
      throw new Error 'not implemented'
  describe 'Create Cucumbers app and Tomatos app and ...', ->
    it 'после прихождения реквеста на томатос, он должен запросить через CucumbersResource огурец (который пошлет запрос через HttpCollectionMixin), полученный огурец он должен отправить в ответе', ->
      throw new Error 'not implemented'
