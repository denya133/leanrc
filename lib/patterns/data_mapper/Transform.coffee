

module.exports = (Module)->
  {
    CoreObject
    Utils: { joi }
  } = Module::

  class Transform extends CoreObject
    @inheritProtected()
    # @implements Module::TransformInterface
    @module Module

    @public @static schema: Object,
      get: -> joi.any().allow(null).optional()

    @public @static @async normalize: Function,
      default: (args...)->
        yield return @normalizeSync args...

    @public @static @async serialize: Function,
      default: (args...)->
        yield return @serializeSync args...

    @public @static normalizeSync: Function,
      default: (serialized)->
        unless serialized?
          return null
        return serialized

    @public @static serializeSync: Function,
      default: (deserialized)->
        unless deserialized?
          return null
        return deserialized

    @public @static objectize: Function,
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
