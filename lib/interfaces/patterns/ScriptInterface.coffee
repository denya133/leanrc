

module.exports = (Module)->
  {
    AnyT
    FuncG, MaybeG
    CommandInterface
  } = Module::

  class ScriptInterface extends CommandInterface
    @inheritProtected()
    @module Module

    @virtual @async body: FuncG [MaybeG AnyT], MaybeG AnyT
    @virtual @static do: FuncG Function


    @initialize()
