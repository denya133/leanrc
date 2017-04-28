RC      = require 'RC'
LeanRC  = require 'LeanRC'

module.exports = (Module) ->
  class Module::Core extends LeanRC::PipeAwareModule
    @inheritProtected()
    @Module: Module

    @public @static NAME: String,
      default: 'GroupsCore'

    constructor: ->
      super Module::CoreFacade.getInstance Module::Core.NAME
      @facade.startup @


  Module::Core.initialize()
