{SELF, NILL, ANY} = FoxxMC::Constants

class ResolvedSpecInterface extends Interface
  @public fullName: String
  @public type: String
  @public fullNameWithoutType: String
  @public dirname: String
  @public name: String
  @public root: String
  @public resolveMethodName: String

class ResolverInterface extends Interface
  @public namespace: ApplicationInterface
  @protected lookupDescription: Function, [fullName], -> String
  @protected parseName: Function, [fullName], -> ResolvedSpecInterface
  @protected useRouterNaming: Function, [ResolvedSpecInterface], -> NILL
  @public resolve: Function, [fullName], -> Object # may be class (factory)
  @protected resolveController: Function, [ResolvedSpecInterface], -> Object # may be class (factory)
  @protected resolveMixin: Function, [ResolvedSpecInterface], -> Object # may be class (factory)
  @protected resolveModel: Function, [ResolvedSpecInterface], -> Object # may be class (factory)
  @protected resolveResource: Function, [ResolvedSpecInterface], -> Object # may be class (factory)
  @protected resolveTemplate: Function, [ResolvedSpecInterface], -> Object # may be class (factory)
  @protected resolveComponent: Function, [ResolvedSpecInterface], -> Object # may be class (factory)
  @protected resolveAdapter: Function, [ResolvedSpecInterface], -> Object # may be class (factory)
  @protected resolveService: Function, [ResolvedSpecInterface], -> Object # may be class (factory)
  @protected resolveTransform: Function, [ResolvedSpecInterface], -> Object # may be class (factory)
  @protected resolveSerializer: Function, [ResolvedSpecInterface], -> Object # may be class (factory)
  @protected resolveInterface: Function, [ResolvedSpecInterface], -> Object # may be class (factory)
  @protected resolveInitializer: Function, [ResolvedSpecInterface], -> Object # may be class (factory)
  @protected resolveOther: Function, [ResolvedSpecInterface], -> Object # may be class (factory)

class Resolver extends CoreObject
  @implements ResolverInterface
