

module.exports = (Module)->
  {
    ANY, NILL, LAMBDA
    TypeT
    Generic, Class, Mixin, Interface
    DictG, UnionG, EnumG
    PropertyDefinitionT
  } = Module::

  PropertyDefinitionT.define DictG String, UnionG(
    EnumG [
      ANY
      NILL
      LAMBDA
      Promise, Module::Promise
      Generic
      Class
      Mixin
      Module::Module
      Interface

      Function
      String
      Number
      Boolean
      Date
      Object
      Array
      Map
      Set
      RegExp
      Symbol
      Error
      Buffer
      (require 'stream')
      (require 'events')
    ]
    TypeT
  )
