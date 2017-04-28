LeanRC = require.main.require 'lib'

module.exports = (Module) ->
  class Module::StartupCommand extends LeanRC::MacroCommand
    @inheritProtected()
    @Module: Module

    @public initializeMacroCommand: Function,
      default: ->
        @addSubCommand Module::PrepareControllerCommand
        @addSubCommand Module::PrepareViewCommand
        @addSubCommand Module::PrepareModelCommand

  Module::StartupCommand.initialize()
