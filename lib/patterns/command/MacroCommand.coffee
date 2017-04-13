RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::MacroCommand extends LeanRC::Notifier
    @inheritProtected()
    @implements LeanRC::CommandInterface

    @Module: LeanRC

    iplSubCommands = @private subCommands: Array

    @public execute: Function,
      default: (aoNotification)->
        vlSubCommands = @[iplSubCommands][..]
        for vCommand in vlSubCommands
          do (vCommand)=>
            voCommand = vCommand.new()
            voCommand.initializeNotifier @[Symbol.for '~multitonKey']
            voCommand.execute aoNotification
        @[iplSubCommands][..]
        return

    @public initializeMacroCommand: Function,
      args: []
      return: RC::Constants.NILL
      default: ->

    @public addSubCommand: Function,
      args: [RC::Class]
      return: RC::Constants.NILL
      default: (aClass)->
        @[iplSubCommands].push aClass
        return

    constructor: ->
      super arguments...

      @[iplSubCommands] = []
      @initializeMacroCommand()


  return LeanRC::MacroCommand.initialize()
