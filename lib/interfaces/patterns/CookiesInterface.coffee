

module.exports = (Module)->
  {
    ANY
    NILL
  } = Module::

  Module.defineInterface (BaseClass) ->
    class CookiesInterface extends BaseClass
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


    CookiesInterface.initializeInterface()
