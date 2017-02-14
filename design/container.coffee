{SELF, NILL, ANY} = FoxxMC::Constants

class ContainerProxyMixinInterface extends Interface
  @public lookup: Function, [fullName, options], -> ANY

class ContainerInterface extends Interface
  @include ContainerProxyMixinInterface

class Container extends CoreObject
  @implements ContainerInterface
