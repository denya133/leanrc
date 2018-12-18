

module.exports = (Module)->
  {
    AnyT
    FuncG, MaybeG
    Interface
  } = Module::

  class PipeMessageInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual getType: FuncG [], String
    @virtual setType: FuncG String
    @virtual getPriority: FuncG [], Number
    @virtual setPriority: FuncG Number
    @virtual getHeader: FuncG [], MaybeG Object
    @virtual setHeader: FuncG Object
    @virtual getBody: FuncG [], MaybeG AnyT
    @virtual setBody: FuncG [MaybeG AnyT]


    @initialize()
