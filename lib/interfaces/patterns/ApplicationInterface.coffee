

module.exports = (Module)->
  {ANY, NILL} = Module::

  Module.defineInterface 'ApplicationInterface', (BaseClass) ->
    class extends BaseClass
      @inheritProtected()

      @public @static @virtual NAME: String
      @public @virtual finish: Function,
        args: []
        return: NILL

      @initializeInterface()
