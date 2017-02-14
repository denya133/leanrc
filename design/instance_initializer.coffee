{SELF, NILL, ANY} = FoxxMC::Constants

class InstanceInitializerInterface extends Interface
  @public name: String
  @public before: [String, NILL]
  @public after: [String, NILL, Array]
  @public initialize: Function, [ApplicationInstanceInterface], -> NILL

class InstanceInitializer extends CoreObject
  @implements InstanceInitializerInterface
