

module.exports = (Module)->
  {
    AnyT
    FuncG
    Interface
  } = Module::

  class MakeSignatureInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual @async makeSignature: FuncG [String, String, AnyT], String
    @virtual @async makeHash: FuncG [String, AnyT], String


    @initialize()
