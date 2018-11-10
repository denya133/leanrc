

module.exports = (Module)->
  {
    JoiT
    FuncG, MaybeG, UnionG
    TransformInterface
    CoreObject
    Utils: { joi }
  } = Module::

  class BooleanTransform extends CoreObject
    @inheritProtected()
    @implements TransformInterface
    @module Module

    @public @static schema: JoiT,
      get: -> joi.boolean().allow(null).optional()

    @public @static @async normalize: FuncG([UnionG Boolean, String, Number], Boolean),
      default: (args...)->
        yield return @normalizeSync args...

    @public @static @async serialize: FuncG([MaybeG UnionG Boolean, String, Number], Boolean),
      default: (args...)->
        yield return @serializeSync args...

    @public @static normalizeSync: FuncG([UnionG Boolean, String, Number], Boolean),
      default: (serialized)->
        type = typeof serialized

        if type is "boolean"
          return serialized
        else if type is "string"
          return serialized.match(/^true$|^t$|^1$/i) isnt null
        else if type is "number"
          return serialized is 1
        else
          return no

    @public @static serializeSync: FuncG([MaybeG UnionG Boolean, String, Number], Boolean),
      default: (deserialized)-> Boolean deserialized

    @public @static objectize: FuncG([MaybeG UnionG Boolean, String, Number], Boolean),
      default: (deserialized)-> Boolean deserialized

    @public @static @async restoreObject: Function,
      default: ->
        throw new Error "restoreObject method not supported for #{@name}"
        yield return

    @public @static @async replicateObject: Function,
      default: ->
        throw new Error "replicateObject method not supported for #{@name}"
        yield return


    @initialize()
