

module.exports = (Module) ->
  {
    MacroCommand
    PrepareViewCommand    
  } = Module::

  class StartupCommand extends MacroCommand
    @inheritProtected()
    @module Module

    @public initializeMacroCommand: Function,
      default: ->
        @addSubCommand PrepareViewCommand

  StartupCommand.initialize()
