

module.exports = (Module)->
  {
    NilT
    FuncG
    Interface
  } = Module::

  class PipeMessageInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual getType: FuncG [], String
    @virtual setType: FuncG String, NilT
    @virtual getPriority: FuncG [], Number
    @virtual setPriority: FuncG Number, NilT
    @virtual getHeader: FuncG [], Object
    @virtual setHeader: FuncG Object, NilT
    @virtual getBody: FuncG [], Object
    @virtual setBody: FuncG Object, NilT


    @initialize()
