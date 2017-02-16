_ = require 'lodash'


module.exports = (FoxxMC)->
  Transform  = require('./Transform') FoxxMC
  StringTransformInterface  = require('../interfaces/string_transform') FoxxMC

  class FoxxMC::StringTransform extends Transform
    @implements StringTransformInterface
    deserialize: (serialized)->
      if _.isNil(serialized) then null else String serialized

    serialize: (deserialized)->
      if _.isNil(deserialized) then null else String deserialized

  FoxxMC::StringTransform.initialize()
