RC      = require 'RC'
LeanRC  = require 'LeanRC'

module.exports = (Module) ->
  class Module::Application extends LeanRC::Application
    @inheritProtected()
    @Module: Module

    @public @static NAME: String,
      default: 'TomatosSchema'


  Module::Application.initialize()
