

module.exports = (Module)->
  {
    JoiT
    FuncG, MaybeG
    TransformInterface
    CoreObject
    Utils: { _, joi }
  } = Module::

  class StringTransform extends CoreObject
    @inheritProtected()
    @implements TransformInterface
    @module Module

    @public @static schema: JoiT,
      get: -> joi.string().allow(null).optional()

    @public @static @async normalize: FuncG([MaybeG String], MaybeG String),
      default: (args...)->
        yield return @normalizeSync args...

    @public @static @async serialize: FuncG([MaybeG String], MaybeG String),
      default: (args...)->
        yield return @serializeSync args...

    @public @static normalizeSync: FuncG([MaybeG String], MaybeG String),
      default: (serialized)->
        return (if _.isNil(serialized) then null else String serialized)

    @public @static serializeSync: FuncG([MaybeG String], MaybeG String),
      default: (deserialized)->
        return (if _.isNil(deserialized) then null else String deserialized)

    @public @static objectize: FuncG([MaybeG String], MaybeG String),
      default: (deserialized)->
        if _.isNil(deserialized) then null else String deserialized

    @public @static @async restoreObject: Function,
      default: ->
        throw new Error "restoreObject method not supported for #{@name}"
        yield return

    @public @static @async replicateObject: Function,
      default: ->
        throw new Error "replicateObject method not supported for #{@name}"
        yield return


    @initialize()
