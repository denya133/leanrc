

module.exports = (Module)->
  {ANY, NILL} = Module::

  Module.defineInterface 'PipeMessageInterface', (BaseClass) ->
    class extends BaseClass
      @inheritProtected()

      @public @static @virtual PRIORITY_HIGH: Number
      @public @static @virtual PRIORITY_MED: Number
      @public @static @virtual PRIORITY_LOW: Number

      @public @static @virtual BASE: String
      @public @static @virtual NORMAL: String
      @public @static @virtual ERROR: String

      @public @virtual getType: Function,
        args: []
        return: String
      @public @virtual setType: Function,
        args: [String]
        return: NILL
      @public @virtual getPriority: Function,
        args: []
        return: Number
      @public @virtual setPriority: Function,
        args: [Number]
        return: NILL
      @public @virtual getHeader: Function,
        args: []
        return: Object
      @public @virtual setHeader: Function,
        args: [Object]
        return: NILL
      @public @virtual getBody: Function,
        args: []
        return: Object
      @public @virtual setBody: Function,
        args: [Object]
        return: NILL


      @initializeInterface()
