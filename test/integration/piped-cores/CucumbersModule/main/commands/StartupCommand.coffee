

module.exports = (Module) ->
  {
    MacroCommand
    PrepareControllerCommand
    PrepareViewCommand
    PrepareModelCommand
    StartMainResqueExecutorCommand
  } = Module::

  class StartupCommand extends MacroCommand
    @inheritProtected()
    @module Module

    @public initializeMacroCommand: Function,
      default: ->
        @addSubCommand PrepareControllerCommand
        @addSubCommand PrepareModelCommand
        @addSubCommand PrepareViewCommand
        # @addSubCommand StartMainResqueExecutorCommand

  StartupCommand.initialize()
