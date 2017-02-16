
module.exports = (FoxxMC)->
  Interface  = require('../Interface') FoxxMC
  {SELF, NILL, ANY} = require('../Constants') FoxxMC

  class FoxxMC::BooleanTransformInterface extends Interface
    @public deserialize: Function
    ,
      [
        serialized: [Boolean, NILL, String, Number]
      ,
        options: Object
      ]
    , ->
      return: [Boolean, NILL]
    @public serialize: Function
    ,
      [
        deserialized: [Boolean, NILL]
      ,
        options: Object
      ]
    , ->
      return: [Boolean, NILL]

  FoxxMC::BooleanTransformInterface.initialize()
