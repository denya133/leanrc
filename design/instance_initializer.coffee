{SELF, NULL, ANY} = FoxxMC::Constants

class InstanceInitializerInterface extends Interface
  @public name: String
  @public before: [String, NULL]
  @public after: [String, NULL, Array]
  @public initialize: Function, [ApplicationInstanceInterface], -> NULL

class InstanceInitializer extends CoreObject
  @implements InstanceInitializerInterface
