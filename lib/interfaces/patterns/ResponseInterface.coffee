Stream = require 'stream'


module.exports = (Module)->
  {
    NilT
    FuncG, UnionG, MaybeG
    SwitchInterface
    Interface
  } = Module::

  class ResponseInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual res: Object
    @virtual switch: SwitchInterface

    @virtual socket: Object
    @virtual header: Object
    @virtual headers: Object

    @virtual status: Number
    @virtual message: String
    @virtual body: UnionG String, Buffer, Object, Stream
    @virtual length: Number
    @virtual headerSent: Boolean
    @virtual vary: FuncG String, NilT
    @virtual redirect: FuncG [String, String], NilT
    @virtual attachment: FuncG String, NilT
    @virtual lastModified: MaybeG Date
    @virtual etag: String
    @virtual type: String
    @virtual is: FuncG [UnionG String, Array], UnionG String, Boolean, NilT
    @virtual get: FuncG String, String
    @virtual set: FuncG [UnionG(String, Object, Array), String], NilT
    @virtual append: FuncG [String, UnionG String, Array], UnionG String, Array
    @virtual remove: FuncG String, NilT
    @virtual writable: Boolean

    # @virtual toJSON: FuncG [], Object
    #
    # @virtual inspect: FuncG [], Object


    @initialize()
