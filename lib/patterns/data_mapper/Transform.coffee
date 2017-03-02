

module.exports = (LeanRC)->
  class LeanRC::Transform extends RC::CoreObject
    @inheritProtected()
    @implements LeanRC::TransformInterface

    @Module: LeanRC

    @public deserialize: Function,
      default: (serialized)->
        unless serialized?
          return null
        serialized

    @public serialize: Function,
      default: (deserialized)->
        unless deserialized?
          return null
        deserialized


  return LeanRC::Transform.initialize()
