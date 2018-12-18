

module.exports = (Module)->
  {
    AnyT
    FuncG, MaybeG
    CookiesInterface: CookiesInterfaceDef
    Interface
  } = Module::

  class CookiesInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual request: Object
    @virtual response: Object
    @virtual key: String

    @virtual get: FuncG [String, MaybeG Object], MaybeG String
    @virtual set: FuncG [String, AnyT, MaybeG Object], CookiesInterfaceDef


    @initialize()
