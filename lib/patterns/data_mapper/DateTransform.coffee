_ = require 'lodash'


module.exports = (Module)->
  class DateTransform extends Module::CoreObject
    @inheritProtected()
    @implements Module::TransformInterface
    @module Module

    @public @static normalize: Function,
      default: (serialized)->
        if _.isNil(serialized) then null else new Date serialized

    @public @static serialize: Function,
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
