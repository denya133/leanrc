

module.exports = (Module)->
  {ANY, NILL} = Module::

  Module.defineInterface (BaseClass) ->
    class ApplicationInterface extends BaseClass
      @inheritProtected()

      @public @static @virtual NAME: String
      @public @virtual finish: Function,
        args: []
        return: NILL

    ApplicationInterface.initializeInterface()
