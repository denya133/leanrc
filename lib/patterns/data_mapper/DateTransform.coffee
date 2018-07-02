

module.exports = (Module)->
  {
    CoreObject
    Utils: { _, joi }
  } = Module::

  class DateTransform extends CoreObject
    @inheritProtected()
    # @implements Module::TransformInterface
    @module Module

    @public @static schema: Object,
      get: -> joi.date().iso().allow(null).optional()

    @public @static @async normalize: Function,
      default: (serialized)->
        yield return (if _.isNil(serialized) then null else new Date serialized)

    @public @static @async serialize: Function,
      default: (deserialized)->
        if _.isDate(deserialized) and not _.isNaN(deserialized)
          yield return deserialized.toISOString()
        else
          yield return null

    @public @static objectize: Function,
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


  DateTransform.initialize()
