

module.exports = (Module)->
  {
    CoreObject
    Utils: { joi }
  } = Module::

  class BooleanTransform extends CoreObject
    @inheritProtected()
    # @implements Module::TransformInterface
    @module Module

    @public @static schema: Object,
      get: -> joi.boolean().allow(null).optional()

    @public @static @async normalize: Function,
      default: (args...)->
        yield return @normalizeSync args...

    @public @static @async serialize: Function,
      default: (args...)->
        yield return @serializeSync args...

    @public @static normalizeSync: Function,
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

    @public @static serializeSync: Function,
      default: (deserialized)->
        return Boolean deserialized

    @public @static objectize: Function,
      default: (deserialized)->
        Boolean deserialized

    @public @static @async restoreObject: Function,
      default: ->
        throw new Error "restoreObject method not supported for #{@name}"
        yield return

    @public @static @async replicateObject: Function,
      default: ->
        throw new Error "replicateObject method not supported for #{@name}"
        yield return


    @initialize()
