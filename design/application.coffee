{SELF, NILL, ANY} = FoxxMC::Constants

class ApplicationInterface extends Interface
  @include RegistryProxyMixinInterface
  @public resolver: ResolverInterface
  @public initialize: Function, [], -> NILL # initializing all application classes (in registry) and make singeltons (services) - call in constructor()
  @public ready: Function, [], -> NILL # called after finished initializing
  @public initializer: Function, [InitializerInterface], -> NILL
  @public instanceInitializer: Function, [InstanceInitializerInterface], -> NILL
  @public buildInstance: Function, [], -> ApplicationInstanceInterface

class Application extends CoreObject
  @implements ApplicationInterface
