
module.exports = (FoxxMC)->
  Interface  = require('../Interface') FoxxMC
  {SELF, NILL, ANY} = require('../Constants') FoxxMC

  class FoxxMC::NumberTransformInterface extends Interface
    @public deserialize: Function
    ,
      [
        serialized: [Number, NILL, String, Boolean, Date]
      ]
    , ->
      return: [Number, NILL]
    @public serialize: Function
    ,
      [
        deserialized: [Number, NILL, String, Boolean, Date]
      ]
    , ->
      return: [Number, NILL]

  FoxxMC::NumberTransformInterface.initialize()
