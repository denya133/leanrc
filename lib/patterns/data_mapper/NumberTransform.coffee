

module.exports = (Module)->
  {
    CoreObject
    Utils: { _, joi }
  } = Module::

  class NumberTransform extends CoreObject
    @inheritProtected()
    # @implements Module::TransformInterface
    @module Module

    @public @static schema: Object,
      get: -> joi.number().allow(null).optional()

    @public @static @async normalize: Function,
      default: (args...)->
        yield return @normalizeSync args...

    @public @static @async serialize: Function,
      default: (args...)->
        yield return @serializeSync args...

    @public @static normalizeSync: Function,
      default: (serialized)->
        if _.isNil serialized
          return null
        else
          transformed = Number serialized
          return (if _.isNumber(transformed) then transformed else null)

    @public @static serializeSync: Function,
      default: (deserialized)->
        if _.isNil deserialized
          return null
        else
          transformed = Number deserialized
          return (if _.isNumber(transformed) then transformed else null)

    @public @static objectize: Function,
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
