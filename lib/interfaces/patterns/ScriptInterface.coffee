

module.exports = (Module)->
  {NILL, LAMBDA} = Module::

  class ScriptInterface extends Module::Interface
    @inheritProtected()

    @module Module

    @public @async @virtual body: Function,
      args: [Object]
      return: [NILL, Error]

    @public @static @virtual do: Function,
      args: [LAMBDA]
      return: String


  ScriptInterface.initialize()
