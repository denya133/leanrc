

module.exports = (FoxxMC)->
  Interface  = require('../Interface') FoxxMC
  {SELF, NILL, ANY} = require('../Constants') FoxxMC

  class FoxxMC::TransformInterface extends Interface
    @public @virtual deserialize: Function # virtual declaration of method
    @public @virtual serialize:   Function # virtual declaration of method

  FoxxMC::TransformInterface.initialize()
