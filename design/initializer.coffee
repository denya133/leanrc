{SELF, NILL, ANY} = FoxxMC::Constants

class InitializerInterface extends Interface
  @public name: String
  @public before: [String, NILL]
  @public after: [String, NILL, Array]
  @public initialize: Function, [ApplicationInterface], -> NILL

class Initializer extends CoreObject
  @implements InitializerInterface
