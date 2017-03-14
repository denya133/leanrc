RC = require 'RC'


module.exports = (LeanRC)->
  class LeanRC::BooleanTransform extends RC::CoreObject
    @inheritProtected()
    @implements LeanRC::TransformInterface

    @Module: LeanRC

    @public @static normalize: Function,
      default: (serialized)->
        type = typeof serialized

        if type is "boolean"
          return serialized
        else if type is "string"
          return serialized.match(/^true$|^t$|^1$/i) isnt null
        else if type is "number"
          return serialized is 1
        else
          return no

    @public @static serialize: Function,
      default: (deserialized)->
        Boolean deserialized


  return LeanRC::BooleanTransform.initialize()
