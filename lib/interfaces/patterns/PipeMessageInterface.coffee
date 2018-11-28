

module.exports = (Module)->
  {
    AnyT, NilT
    FuncG, MaybeG
    Interface
  } = Module::

  class PipeMessageInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual getType: FuncG [], String
    @virtual setType: FuncG String, NilT
    @virtual getPriority: FuncG [], Number
    @virtual setPriority: FuncG Number, NilT
    @virtual getHeader: FuncG [], MaybeG Object
    @virtual setHeader: FuncG Object, NilT
    @virtual getBody: FuncG [], MaybeG AnyT
    @virtual setBody: FuncG [MaybeG AnyT], NilT


    @initialize()
