

module.exports = (Module)->
  {
    AnyT, NilT
    FuncG, MaybeG
    Interface
  } = Module::

  class NotificationInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual getName: FuncG [], String
    @virtual setBody: FuncG [MaybeG AnyT], NilT
    @virtual getBody: FuncG [], MaybeG AnyT
    @virtual setType: FuncG String, NilT
    @virtual getType: FuncG [], MaybeG String


    @initialize()
