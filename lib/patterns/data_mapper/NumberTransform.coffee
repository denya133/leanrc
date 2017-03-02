_ = require 'lodash'


module.exports = (FoxxMC)->
  Transform  = require('./Transform') FoxxMC
  NumberTransformInterface  = require('../interfaces/number_transform') FoxxMC

  class FoxxMC::NumberTransform extends Transform
    @implements NumberTransformInterface
    @instanceMethod 'deserialize', (serialized)->
      if _.isEmpty serialized
        return null
      else
        transformed = Number serialized
        return if _.isNumber(transformed) then transformed else null

    @instanceMethod 'serialize', (deserialized)->
      if _.isEmpty deserialized
        return null
      else
        transformed = Number deserialized
        return if _.isNumber(transformed) then transformed else null

  FoxxMC::NumberTransform.initialize()
