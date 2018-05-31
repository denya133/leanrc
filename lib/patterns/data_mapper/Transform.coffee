

module.exports = (Module)->
  class Transform extends Module::CoreObject
    @inheritProtected()
    # @implements Module::TransformInterface
    @module Module

    @public @static @async normalize: Function,
      default: (serialized)->
        unless serialized?
          yield return null
        yield return serialized

    @public @static @async serialize: Function,
      default: (deserialized)->
        unless deserialized?
          yield return null
        yield return deserialized

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


  Transform.initialize()
