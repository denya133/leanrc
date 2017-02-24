RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::MacroCommand extends LeanRC::Notifier
    @implements LeanRC::CommandInterface

    @public execute: Function,
      default: (notification)->
        subCommands = @subCommands.slice 0
        for vCommand in subCommands
          do (vCommand)=>
            command = vCommand.new()
            command.initializeNotifier @multitonKey
            command.execute notification
        @subCommands.slice 0
        return


    @private subCommands: Array
    @protected initializeMacroCommand: Function,
      args: []
      return: RC::Constants.NILL
      default: ->

    @protected addSubCommand: Function,
      args: [RC::Class]
      return: RC::Constants.NILL
      default: (aClass)->
        @subCommands.push aClass
        return

    constructor: ->
      @super('constructor') arguments

      @subCommands = []
      @initializeMacroCommand()




  return LeanRC::MacroCommand.initialize()
