
module.exports = (FoxxMC)->
  Interface  = require('../Interface') FoxxMC
  {SELF, NILL, ANY} = require('../Constants') FoxxMC

  class FoxxMC::DateTransformInterface extends Interface
    @public deserialize: Function
    ,
      [
        serialized: [Date, NILL, String, Boolean, Number]
      ]
    , ->
      return: [Date, NILL]
    @public serialize: Function
    ,
      [
        deserialized: [Date, NILL, String, Boolean, Number]
      ]
    , ->
      return: [Date, NILL]

  FoxxMC::DateTransformInterface.initialize()
