

module.exports = (Module)->
  {
    NilT
    FuncG
    NotificationInterface
    CommandInterface
    Notifier
  } = Module::

  class SimpleCommand extends Notifier
    @inheritProtected()
    @implements CommandInterface
    @module Module

    @public execute: FuncG(NotificationInterface),
      default: ->

    @public @static @async restoreObject: Function,
      default: ->
        throw new Error "restoreObject method not supported for #{@name}"
        yield return

    @public @static @async replicateObject: Function,
      default: ->
        throw new Error "replicateObject method not supported for #{@name}"
        yield return


    @initialize()
