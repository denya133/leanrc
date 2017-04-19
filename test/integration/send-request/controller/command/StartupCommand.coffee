

module.exports = (Module) ->
  class StartupCommand extends Module::MacroCommand
    @inheritProtected()
    @Module: Module

    @public initializeMacroCommand: Function,
      default: ->
        @addSubCommand Module::PrepareControllerCommand
        @addSubCommand Module::PrepareViewCommand
        @addSubCommand Module::PrepareModelCommand

  StartupCommand.initialize()
