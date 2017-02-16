
module.exports = (FoxxMC)->
  Interface  = require('../Interface') FoxxMC
  {SELF, NILL, ANY} = require('../Constants') FoxxMC

  class FoxxMC::StringTransformInterface extends Interface
    @public deserialize: Function
    ,
      [
        serialized: [String, NILL, Number, Boolean, Date]
      ]
    , ->
      return: [String, NILL]
    @public serialize: Function
    ,
      [
        deserialized: [String, NILL, Number, Boolean, Date]
      ]
    , ->
      return: [String, NILL]

  FoxxMC::StringTransformInterface.initialize()
