

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
      get: ->
        joi.boolean().empty(null).default(null)

    @public @static @async normalize: Function,
      default: (serialized)->
        type = typeof serialized

        if type is "boolean"
          yield return serialized
        else if type is "string"
          yield return serialized.match(/^true$|^t$|^1$/i) isnt null
        else if type is "number"
          yield return serialized is 1
        else
          yield return no

    @public @static @async serialize: Function,
      default: (deserialized)->
        yield return Boolean deserialized

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


  BooleanTransform.initialize()
