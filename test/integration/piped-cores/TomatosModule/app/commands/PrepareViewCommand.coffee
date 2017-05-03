RC      = require 'RC'
LeanRC  = require 'LeanRC'

module.exports = (Module) ->
  class Module::PrepareViewCommand extends LeanRC::SimpleCommand
    @inheritProtected()
    @Module: Module

    @public execute: Function,
      default: (aoNotification)->
        voApplication = aoNotification.getBody()
        @facade.registerMediator Module::ApplicationMediator.new 'ApplicationMediator', voApplication
        @facade.registerMediator Module::ShellJunctionMediator.new()


  Module::PrepareViewCommand.initialize()
