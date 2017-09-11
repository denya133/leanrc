

module.exports = (Module)->
  {ANY, NILL} = Module::

  class MacroCommand extends Module::Notifier
    @inheritProtected()
    # @implements Module::CommandInterface
    @module Module

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
      return: NILL
      default: ->

    @public addSubCommand: Function,
      args: [Module::Class]
      return: NILL
      default: (aClass)->
        @[iplSubCommands].push aClass
        return

    @public init: Function,
      default: ->
        @super arguments...

        @[iplSubCommands] = []
        @initializeMacroCommand()

    @public @static @async restoreObject: Function,
      default: ->
        throw new Error "restoreObject method not supported for #{@name}"
        yield return

    @public @static @async replicateObject: Function,
      default: ->
        throw new Error "replicateObject method not supported for #{@name}"
        yield return


  MacroCommand.initialize()
