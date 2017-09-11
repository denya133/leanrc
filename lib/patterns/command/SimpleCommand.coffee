

module.exports = (Module)->
  class SimpleCommand extends Module::Notifier
    @inheritProtected()
    # @implements Module::CommandInterface
    @module Module

    @public execute: Function,
      default: ->

    @public @static @async restoreObject: Function,
      default: ->
        throw new Error "restoreObject method not supported for #{@name}"
        yield return

    @public @static @async replicateObject: Function,
      default: ->
        throw new Error "replicateObject method not supported for #{@name}"
        yield return


  SimpleCommand.initialize()
