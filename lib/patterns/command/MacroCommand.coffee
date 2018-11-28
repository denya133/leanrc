

module.exports = (Module)->
  {
    NilT
    ListG, FuncG, SubsetG
    CommandInterface, NotificationInterface
    Notifier
  } = Module::

  class MacroCommand extends Notifier
    @inheritProtected()
    @implements CommandInterface
    @module Module

    iplSubCommands = @private subCommands: ListG SubsetG CommandInterface

    @public execute: FuncG(NotificationInterface),
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
      default: ->

    @public addSubCommand: FuncG([SubsetG CommandInterface], NilT),
      default: (aClass)->
        @[iplSubCommands].push aClass
        return

    @public init: Function,
      default: ->
        @super arguments...

        @[iplSubCommands] = []
        @initializeMacroCommand()
        return

    @public @static @async restoreObject: Function,
      default: ->
        throw new Error "restoreObject method not supported for #{@name}"
        yield return

    @public @static @async replicateObject: Function,
      default: ->
        throw new Error "replicateObject method not supported for #{@name}"
        yield return


    @initialize()
