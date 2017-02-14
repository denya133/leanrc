{SELF, NILL, ANY} = FoxxMC::Constants

class ApplicationInstanceInterface extends Interface
  @include RegistryProxyMixinInterface
  @include ContainerProxyMixinInterface
  @public unregister: Function, [fullName], -> NILL #Overrides `RegistryProxy#unregister` in order to clear any cached instances of the unregistered factory.

class ApplicationInstance extends CoreObject
  @implements ApplicationInstanceInterface
