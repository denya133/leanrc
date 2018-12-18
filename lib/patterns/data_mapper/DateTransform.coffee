

module.exports = (Module)->
  {
    JoiT
    FuncG, MaybeG
    TransformInterface
    CoreObject
    Utils: { _, joi }
  } = Module::

  class DateTransform extends CoreObject
    @inheritProtected()
    @implements TransformInterface
    @module Module

    @public @static schema: JoiT,
      get: -> joi.date().iso().allow(null).optional()

    @public @static @async normalize: FuncG([MaybeG String], MaybeG Date),
      default: (args...)->
        yield return @normalizeSync args...

    @public @static @async serialize: FuncG([MaybeG Date], MaybeG String),
      default: (args...)->
        yield return @serializeSync args...

    @public @static normalizeSync: FuncG([MaybeG String], MaybeG Date),
      default: (serialized)->
        return (if _.isNil(serialized) then null else new Date serialized)

    @public @static serializeSync: FuncG([MaybeG Date], MaybeG String),
      default: (deserialized)->
        if _.isDate(deserialized) and not _.isNaN(deserialized)
          return deserialized.toISOString()
        else
          return null

    @public @static objectize: FuncG([MaybeG Date], MaybeG String),
      default: (deserialized)->
        if _.isDate(deserialized) and not _.isNaN(deserialized)
          return deserialized.toISOString()
        else
          return null

    @public @static @async restoreObject: Function,
      default: ->
        throw new Error "restoreObject method not supported for #{@name}"
        yield return

    @public @static @async replicateObject: Function,
      default: ->
        throw new Error "replicateObject method not supported for #{@name}"
        yield return


    @initialize()
