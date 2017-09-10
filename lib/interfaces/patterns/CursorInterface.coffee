

module.exports = (Module)->
  {ANY, NILL} = Module::

  Module.defineInterface (BaseClass) ->
    class CursorInterface extends BaseClass
      @inheritProtected()

      @public @virtual setCollection: Function,
        args: [Module::ProxyInterface]
        return: CursorInterface

      @public @virtual setIterable: Function,
        args: [ANY]
        return: CursorInterface

      @public @async @virtual toArray: Function,
        args: []
        return: Array

      @public @async @virtual next: Function,
        args: []
        return: ANY

      @public @async @virtual hasNext: Function,
        args: []
        return: Boolean

      @public @async @virtual close: Function,
        args: []
        return: NILL

      @public @async @virtual count: Function,
        args: []
        return: Number

      @public @async @virtual forEach: Function,
        args: [Function]
        return: NILL

      @public @async @virtual map: Function,
        args: [Function]
        return: Array

      @public @async @virtual filter: Function,
        args: [Function]
        return: Array

      @public @async @virtual find: Function,
        args: [Function]
        return: ANY

      @public @async @virtual compact: Function,
        args: []
        return: Array

      @public @async @virtual reduce: Function,
        args: [Function, ANY]
        return: ANY

      @public @async @virtual first: Function,
        args: []
        return: ANY


    CursorInterface.initializeInterface()
