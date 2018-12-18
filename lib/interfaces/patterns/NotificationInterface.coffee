

module.exports = (Module)->
  {
    AnyT
    FuncG, MaybeG
    Interface
  } = Module::

  class NotificationInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual getName: FuncG [], String
    @virtual setBody: FuncG [MaybeG AnyT]
    @virtual getBody: FuncG [], MaybeG AnyT
    @virtual setType: FuncG String
    @virtual getType: FuncG [], MaybeG String


    @initialize()
