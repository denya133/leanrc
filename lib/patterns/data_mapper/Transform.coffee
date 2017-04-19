

module.exports = (Module)->
  class Transform extends Module::CoreObject
    @inheritProtected()
    @implements Module::TransformInterface

    @Module: Module

    @public @static normalize: Function,
      default: (serialized)->
        unless serialized?
          return null
        serialized

    @public @static serialize: Function,
      default: (deserialized)->
        unless deserialized?
          return null
        deserialized


  Transform.initialize()
