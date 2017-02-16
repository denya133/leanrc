

module.exports = (FoxxMC)->
  Interface  = require('../Interface') FoxxMC

  class FoxxMC::ServiceInterface extends Interface
    @public @static isServiceFactory: Boolean

  FoxxMC::ServiceInterface.initialize()
