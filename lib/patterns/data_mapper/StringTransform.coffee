

module.exports = (Module)->
  {
    CoreObject
    Utils: { _, joi }
  } = Module::

  class StringTransform extends CoreObject
    @inheritProtected()
    # @implements Module::TransformInterface
    @module Module

    @public @static schema: Object,
      get: -> joi.string().allow(null).optional()

    @public @static @async normalize: Function,
      default: (args...)->
        yield return @normalizeSync args...

    @public @static @async serialize: Function,
      default: (args...)->
        yield return @serializeSync args...

    @public @static normalizeSync: Function,
      default: (serialized)->
        return (if _.isNil(serialized) then null else String serialized)

    @public @static serializeSync: Function,
      default: (deserialized)->
        return (if _.isNil(deserialized) then null else String deserialized)

    @public @static objectize: Function,
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
