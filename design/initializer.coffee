{SELF, NULL, ANY} = FoxxMC::Constants

class InitializerInterface extends Interface
  @public name: String
  @public before: [String, NULL]
  @public after: [String, NULL, Array]
  @public initialize: Function, [ApplicationInterface], -> NULL

class Initializer extends CoreObject
  @implements InitializerInterface
