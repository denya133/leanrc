RC      = require 'RC'
LeanRC  = require 'LeanRC'

module.exports = (Module) ->
  class Module::Client extends LeanRC::PipeAwareModule
    @inheritProtected()
    @Module: Module

    @public @static NAME: String,
      default: 'GroupsClient'

    constructor: ->
      super Module::ClientFacade.getInstance Module::Client.NAME
      @facade.startup @


  Module::Client.initialize()
