

module.exports = (Module)->
  {NILL, LAMBDA} = Module::

  Module.defineInterface (BaseClass) ->
    class ScriptInterface extends BaseClass
      @inheritProtected()

      @public @async @virtual body: Function,
        args: [Object]
        return: [NILL, Error]

      @public @static @virtual do: Function,
        args: [LAMBDA]
        return: String


    ScriptInterface.initializeInterface()
