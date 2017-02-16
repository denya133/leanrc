
module.exports = (FoxxMC)->
  Transform  = require('./Transform') FoxxMC
  BooleanTransformInterface  = require('../interfaces/boolean_transform') FoxxMC

  class FoxxMC::BooleanTransform extends Transform
    @implements BooleanTransformInterface
    deserialize: (serialized, options)->
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
    serialize: (deserialized, options)->
      if not deserialized? and options.allowNull is yes
        return null

      return Boolean deserialized

  FoxxMC::BooleanTransform.initialize()
