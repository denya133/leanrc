{SELF, NILL, ANY} = FoxxMC::Constants

class RegistryProxyMixinInterface extends Interface
  @public hasRegistration: Function, [fullName], -> Boolean
  @public inject: Function, [factoryNameOrType, property, injectionName], -> NILL
  @public register: Function, [fullName, factory, options], -> NILL
  @public registerOption: Function, [fullName, optionName, options], -> NILL
  @public registerOptions: Function, [fullName, options], -> NILL
  @public registerOptionsForType: Function, [type, options], -> NILL
  @public registeredOption: Function, [fullName, optionName], -> Object
  @public registeredOptions: Function, [fullName], -> Object
  @public registeredOptionsForType: Function, [type], -> Object
  @public resolveRegistration: Function, [fullName], -> Function
  @public unregister: Function, [fullName], -> NILL

class RegistryInterface extends Interface
  @include RegistryProxyMixinInterface
  @public container: Function, [], -> ContainerInterface

class Registry extends CoreObject
  @implements RegistryInterface
