

module.exports = (Module)->
  {
    JoiT, AnyT
    FuncG, MaybeG
    TransformInterface
    CoreObject
    Utils: { joi }
  } = Module::

  class Transform extends CoreObject
    @inheritProtected()
    @implements TransformInterface
    @module Module

    @public @static schema: JoiT,
      get: -> joi.any().allow(null).optional()

    @public @static @async normalize: FuncG([MaybeG AnyT], MaybeG AnyT),
      default: (args...)->
        yield return @normalizeSync args...

    @public @static @async serialize: FuncG([MaybeG AnyT], MaybeG AnyT),
      default: (args...)->
        yield return @serializeSync args...

    @public @static normalizeSync: FuncG([MaybeG AnyT], MaybeG AnyT),
      default: (serialized)->
        unless serialized?
          return null
        return serialized

    @public @static serializeSync: FuncG([MaybeG AnyT], MaybeG AnyT),
      default: (deserialized)->
        unless deserialized?
          return null
        return deserialized

    @public @static objectize: FuncG([MaybeG AnyT], MaybeG AnyT),
      default: (deserialized)->
        unless deserialized?
          return null
        deserialized

    @public @static @async restoreObject: Function,
      default: ->
        throw new Error "restoreObject method not supported for #{@name}"
        yield return

    @public @static @async replicateObject: Function,
      default: ->
        throw new Error "replicateObject method not supported for #{@name}"
        yield return


    @initialize()
