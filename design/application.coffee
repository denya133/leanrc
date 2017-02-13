{SELF, NULL, ANY} = FoxxMC::Constants

class ApplicationInterface extends Interface
  @include RegistryProxyMixinInterface
  @public resolver: ResolverInterface
  @public initialize: Function, [], -> NULL # initializing all application classes (in registry) and make singeltons (services) - call in constructor()
  @public ready: Function, [], -> NULL # called after finished initializing
  @public initializer: Function, [InitializerInterface], -> NULL
  @public instanceInitializer: Function, [InstanceInitializerInterface], -> NULL
  @public buildInstance: Function, [], -> ApplicationInstanceInterface

class Application extends CoreObject
  @implements ApplicationInterface
