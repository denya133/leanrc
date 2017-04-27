

module.exports = (Module)->
  {ANY, NILL} = Module::

  Module.defineInterface 'CursorInterface', (BaseClass) ->
    class CursorInterface extends BaseClass
      @inheritProtected()

      @module Module

      @public @virtual setRecord: Function,
        args: [Module::Class]
        return: Module::CursorInterface

      @public @async @virtual toArray: Function,
        args: [[Module::Class, NILL]]
        return: Array

      @public @async @virtual next: Function,
        args: [[Module::Class, NILL]]
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
        args: [Function, [Module::Class, NILL]]
        return: NILL

      @public @async @virtual map: Function,
        args: [Function, [Module::Class, NILL]]
        return: Array

      @public @async @virtual filter: Function,
        args: [Function, [Module::Class, NILL]]
        return: Array

      @public @async @virtual find: Function,
        args: [Function, [Module::Class, NILL]]
        return: ANY

      @public @async @virtual compact: Function,
        args: [[Module::Class, NILL]]
        return: Array

      @public @async @virtual reduce: Function,
        args: [Function, ANY, [Module::Class, NILL]]
        return: ANY

      @public @async @virtual first: Function,
        args: [[Module::Class, NILL]]
        return: ANY


    CursorInterface.initializeInterface()
