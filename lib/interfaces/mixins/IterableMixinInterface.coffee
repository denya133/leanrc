

module.exports = (Module)->
  {ANY, NILL} = Module::

  Module.defineInterface 'IterableMixinInterface', (BaseClass) ->
    class extends BaseClass
      @inheritProtected()

      @public @async @virtual forEach: Function,
        args: [Function]
        return: NILL
      @public @async @virtual filter: Function,
        args: [Function]
        return: Array
      @public @async @virtual map: Function,
        args: [Function]
        return: Array
      @public @async @virtual reduce: Function,
        args: [Function, ANY]
        return: ANY


      @initializeInterface()
