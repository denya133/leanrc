

module.exports = (Module) ->
  {
    MacroCommand
    PrepareControllerCommand
    PrepareViewCommand
    PrepareModelCommand
  } = Module::

  class StartupCommand extends MacroCommand
    @inheritProtected()
    @module Module

    @public initializeMacroCommand: Function,
      default: ->
        @addSubCommand PrepareControllerCommand
        @addSubCommand PrepareViewCommand
        @addSubCommand PrepareModelCommand

  StartupCommand.initialize()
