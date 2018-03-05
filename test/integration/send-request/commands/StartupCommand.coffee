

module.exports = (Module) ->
  class StartupCommand extends Module.NS.MacroCommand
    @inheritProtected()
    @module Module

    @public initializeMacroCommand: Function,
      default: ->
        @addSubCommand Module.NS.PrepareControllerCommand
        @addSubCommand Module.NS.PrepareViewCommand
        @addSubCommand Module.NS.PrepareModelCommand

  StartupCommand.initialize()
