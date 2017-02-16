

module.exports = (FoxxMC)->
  CoreObject  = require('./CoreObject') FoxxMC
  ServiceInterface = require('./interfaces/service') FoxxMC

  class FoxxMC::Service extends CoreObject
    @implements ServiceInterface

    # public
    @defineAccessor Boolean, 'isServiceFactory', yes


  FoxxMC::Service.initialize()
