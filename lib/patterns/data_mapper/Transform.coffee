RC = require 'RC'


module.exports = (LeanRC)->
  class LeanRC::Transform extends RC::CoreObject
    @inheritProtected()
    @implements LeanRC::TransformInterface

    @Module: LeanRC

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


  return LeanRC::Transform.initialize()
