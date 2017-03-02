RC = require 'RC'


module.exports = (LeanRC)->
  class LeanRC::BooleanTransform extends RC::CoreObject
    @inheritProtected()
    @implements LeanRC::TransformInterface

    @Module: LeanRC

    @public deserialize: Function,
      default: (serialized, options)->
        type = typeof serialized

        if not serialized? and options.allowNull is yes
          return null

        if type is "boolean"
          return serialized
        else if type is "string"
          return serialized.match(/^true$|^t$|^1$/i) isnt null
        else if type is "number"
          return serialized is 1
        else
          return no

    @public serialize: Function,
      default: (deserialized, options)->
        if not deserialized? and options.allowNull is yes
          return null

        return Boolean deserialized


  return LeanRC::BooleanTransform.initialize()
