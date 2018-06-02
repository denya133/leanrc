

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
      get: ->
        joi.number().empty(null).default(null)

    @public @static @async normalize: Function,
      default: (serialized)->
        if _.isNil serialized
          yield return null
        else
          transformed = Number serialized
          yield return (if _.isNumber(transformed) then transformed else null)

    @public @static @async serialize: Function,
      default: (deserialized)->
        if _.isNil deserialized
          yield return null
        else
          transformed = Number deserialized
          yield return (if _.isNumber(transformed) then transformed else null)

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


  NumberTransform.initialize()
