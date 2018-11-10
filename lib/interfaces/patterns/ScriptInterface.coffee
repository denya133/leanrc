

module.exports = (Module)->
  {
    AnyT, NilT
    FuncG
    CommandInterface
  } = Module::

  class ScriptInterface extends CommandInterface
    @inheritProtected()
    @module Module

    @virtual @async body: FuncG AnyT, AnyT
    @virtual @static do: FuncG Function, NilT


    @initialize()
