RC      = require 'RC'
LeanRC  = require 'LeanRC'

module.exports = (App)->
  class App::ApplicationRouter extends LeanRC::Router
    @inheritProtected()
    @Module: App

    @map ->
      @namespace 'version', module: '', prefix: ':v', ->
        @resource 'spaces'
        @resource 'companies'
        @resource 'user_companies'
        @resource 'teams'


  return App::ApplicationRouter.initialize()
