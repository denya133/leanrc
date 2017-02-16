_ = require 'lodash'


module.exports = (FoxxMC)->
  Transform  = require('./Transform') FoxxMC
  StringTransformInterface  = require('../interfaces/string_transform') FoxxMC

  class FoxxMC::StringTransform extends Transform
    @implements StringTransformInterface
    deserialize: (serialized)->
      if _.isNil(serialized) then null else Date serialized

    serialize: (deserialized)->
      if deserialized instanceof Date and not _.isNaN deserialized
        return deserialized.toISOString()
      else
        return null

  FoxxMC::StringTransform.initialize()
