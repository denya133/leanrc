_ = require 'lodash'


module.exports = (Module)->
  class StringTransform extends Module::CoreObject
    @inheritProtected()
    @implements Module::TransformInterface
    @module Module

    @public @static normalize: Function,
      default: (serialized)->
        if _.isNil(serialized) then null else String serialized

    @public @static serialize: Function,
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
