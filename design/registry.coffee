{SELF, NULL, ANY} = FoxxMC::Constants

class RegistryProxyMixinInterface extends Interface
  @public hasRegistration: Function, [fullName], -> Boolean
  @public inject: Function, [factoryNameOrType, property, injectionName], -> NULL
  @public register: Function, [fullName, factory, options], -> NULL
  @public registerOption: Function, [fullName, optionName, options], -> NULL
  @public registerOptions: Function, [fullName, options], -> NULL
  @public registerOptionsForType: Function, [type, options], -> NULL
  @public registeredOption: Function, [fullName, optionName], -> Object
  @public registeredOptions: Function, [fullName], -> Object
  @public registeredOptionsForType: Function, [type], -> Object
  @public resolveRegistration: Function, [fullName], -> Function
  @public unregister: Function, [fullName], -> NULL

class RegistryInterface extends Interface
  @include RegistryProxyMixinInterface
  @public container: Function, [], -> ContainerInterface

class Registry extends CoreObject
  @implements RegistryInterface
