

module.exports = (Module)->
  {
    JoiT
    FuncG, MaybeG
    TransformInterface
    CoreObject
    Utils: { _, joi }
  } = Module::

  class NumberTransform extends CoreObject
    @inheritProtected()
    @implements TransformInterface
    @module Module

    @public @static schema: JoiT,
      get: -> joi.number().allow(null).optional()

    @public @static @async normalize: FuncG([MaybeG Number], MaybeG Number),
      default: (args...)->
        yield return @normalizeSync args...

    @public @static @async serialize: FuncG([MaybeG Number], MaybeG Number),
      default: (args...)->
        yield return @serializeSync args...

    @public @static normalizeSync: FuncG([MaybeG Number], MaybeG Number),
      default: (serialized)->
        if _.isNil serialized
          return null
        else
          transformed = Number serialized
          return (if _.isNumber(transformed) then transformed else null)

    @public @static serializeSync: FuncG([MaybeG Number], MaybeG Number),
      default: (deserialized)->
        if _.isNil deserialized
          return null
        else
          transformed = Number deserialized
          return (if _.isNumber(transformed) then transformed else null)

    @public @static objectize: FuncG([MaybeG Number], MaybeG Number),
      default: (deserialized)->
        if _.isNil deserialized
          return null
        else
          transformed = Number deserialized
          return if _.isNumber(transformed) then transformed else null

    @public @static @async restoreObject: Function,
      default: ->
        throw new Error "restoreObject method not supported for #{@name}"
        yield return

    @public @static @async replicateObject: Function,
      default: ->
        throw new Error "replicateObject method not supported for #{@name}"
        yield return


    @initialize()
