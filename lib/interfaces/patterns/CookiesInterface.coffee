

module.exports = (Module)->
  {
    ANY
    NILL
  } = Module::

  Module.defineInterface 'CookiesInterface', (BaseClass) ->
    class extends BaseClass
      @inheritProtected()

      @public @virtual request: Object
      @public @virtual response: Object
      @public @virtual key: String

      @public @virtual get: Function,
        args: [String, [Object, NILL]]
        return: String

      @public @virtual set: Function,
        args: [String, ANY, [Object, NILL]]
        return: CookiesInterface


      @initializeInterface()
