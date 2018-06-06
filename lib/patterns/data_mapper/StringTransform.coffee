

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
      get: -> joi.string().empty(null).default(null)

    @public @static @async normalize: Function,
      default: (serialized)->
        yield return (if _.isNil(serialized) then null else String serialized)

    @public @static @async serialize: Function,
      default: (deserialized)->
        yield return (if _.isNil(deserialized) then null else String deserialized)

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


  StringTransform.initialize()
