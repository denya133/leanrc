{SELF, NILL, ANY, CLASS} = FoxxMC::Constants

class CrudMixinInterface extends Interface
  @private @static Model: CLASS
  @private record: [NILL, ANY]
  @private records: [NILL, Array]

  @public list: Function, [Object], -> Array
  @public detail: Function, [String], -> ANY
  @public create: Function, [Object], -> ANY
  @public update: Function, [String, Object], -> ANY
  @public delete: Function, [String], -> ANY

  @public beforeList: Function, [], -> NILL
  @public beforeDetail: Function, [], -> NILL
  @public beforeCreate: Function, [], -> NILL
  @public beforeUpdate: Function, [], -> NILL
  @public beforeDelete: Function, [], -> NILL
  @public afterList: Function, [ANY], -> ANY
  @public afterDetail: Function, [ANY], -> ANY
  @public afterCreate: Function, [ANY], -> ANY
  @public afterUpdate: Function, [ANY], -> ANY
  @public afterDelete: Function, [ANY], -> ANY

class CrudMixin extends Mixin
  @implements CrudMixinInterface

class ResourceInterface extends Interface
  @private controller: ControllerInterface # setted by constructor()

class Resource extends CoreObject
  @implements ResourceInterface

# example in usage
###
```coffee
class CucumberResource extends Resource
  @include CrudMixin
  @Model: Cucumber
```
###
