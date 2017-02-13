{SELF, NULL, ANY} = FoxxMC::Constants

class ServiceInterface extends Interface
  @public @static isServiceFactory: Boolean

class Service extends CoreObject
  @implements ServiceInterface
  @isServiceFactory: yes
