Stream = require 'stream'


module.exports = (Module)->
  {
    AnyT, NilT
    FuncG, UnionG, MaybeG
    SwitchInterface
    Interface
  } = Module::

  class ResponseInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual res: Object
    @virtual switch: SwitchInterface

    # @virtual socket: Object
    # @virtual header: Object
    # @virtual headers: Object

    # @virtual status: MaybeG Number
    # @virtual message: String
    # @virtual body: MaybeG UnionG String, Buffer, Object, Array, Number, Boolean, Stream
    # @virtual length: Number
    # @virtual headerSent: MaybeG Boolean
    @virtual vary: FuncG String
    @virtual redirect: FuncG [String, MaybeG String]
    @virtual attachment: FuncG String
    # @virtual lastModified: MaybeG Date
    # @virtual etag: String
    # @virtual type: MaybeG String
    @virtual is: FuncG [UnionG String, Array], UnionG String, Boolean, NilT
    @virtual get: FuncG String, UnionG String, Array
    @virtual set: FuncG [UnionG(String, Object), MaybeG AnyT]
    @virtual append: FuncG [String, UnionG String, Array]
    @virtual remove: FuncG String
    # @virtual writable: Boolean

    # @virtual toJSON: FuncG [], Object
    #
    # @virtual inspect: FuncG [], Object


    @initialize()
