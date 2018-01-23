

module.exports = (Module)->
  {NILL, LAMBDA} = Module::

  Module.defineInterface 'ScriptInterface', (BaseClass) ->
    class extends BaseClass
      @inheritProtected()

      @public @async @virtual body: Function,
        args: [Object]
        return: [NILL, Error]

      @public @static @virtual do: Function,
        args: [LAMBDA]
        return: String


      @initializeInterface()
