{SELF, NILL} = FoxxMC::Constants

class ModuleInterface extends  CoreObject
  @public @virtual 'Utils'
  @public @virtual 'Scripts'
  @public @static @virtual 'context'
  @public @static Module: SELF

  @private @static getClassesFor: Function, [String], -> NILL
  @private @static initializeModules: Function, [], -> NILL

  @public @static use: Function, [], -> FoxxMC::RouterInterface
  @public @static initialize: Function, [], -> SELF

class FoxxMC::Module extends CoreObject
  @implements ModuleInterface
