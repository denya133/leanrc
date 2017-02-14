{SELF, NILL, ANY, CLASS} = FoxxMC::Constants

class Core
  @implements: ->

class CoreObjectInterface extends Interface
  @public @static chains: Function, [[Array, String]], -> NILL
  @private @static _chains: Function, [], -> Array
  @private @static _currentSM: String
  @private @static _currentEvent: String
  @public @static super: Function, [String], -> ANY
  @public super: Function, [String], -> ANY
  @public @static new: Function, [Object], -> CoreObjectInterface
  @public save: Function, [], -> CoreObjectInterface
  @public @static defineProperty: Function, [name, definition], -> NILL
  @public @static defineClassProperty: Function, [name, definition], -> NILL
  @public @static defineGetter: Function, [aName, aDefault, aGetter], -> NILL
  @public @static defineSetter: Function, [Class, aName, aSetter], -> NILL
  @public @static defineAccessor: Function, [Class, aName, aDefault, aGetter, aSetter], -> NILL
  @public @static defineClassGetter: Function, [aName, aDefault, aGetter], -> NILL
  @public @static defineClassSetter: Function, [Class, aName, aSetter], -> NILL
  @public @static defineClassAccessor: Function, [Class, aName, aDefault, aGetter, aSetter], -> NILL

  @public @static moduleName: Function, [], -> String
  @private @static _functor: Function, ANY, -> Function
  @public @static method: Function, ANY, -> Function
  @public @static instanceMethod: Function, ANY, -> Function
  @public @static classMethod: Function, ANY, -> Function
  @public @static initialize: Function, [[CLASS, NILL]], -> CLASS

  @public @static publish: Function, [opts], -> Function
  @public @static pub: Function, [opts], -> Function
  @public publish: Function, [opts], -> Function
  @public pub: Function, [opts], -> Function
  @public @static sub: Function, ANY, -> Function
  @public @static subscribe: Function, ANY, -> Function
  @private @static _subs: Function, [[CLASS, NILL]], -> Object

  @public @static delayJob: Function, [data, options], -> NILL
  @public @static delay: Function, [options], -> Object

  @public @static locks: Object
  @public @static _mergeLocks: Function, [collections, otherCollections], -> collections
  @public @static mergeLocks: Function, [collections, otherCollections], -> collections
  @public @static getLocksFor: Function, [keys, processedMethods], -> collections

  @public callAsChain: Function, ANY, -> ANY
  @public collectionsInChain: Function, [methodName], -> Object
  @public methodsInChain: Function, [methodName], -> Array

  @public @static initialHook: Function, [method, options], -> NILL
  @public @static beforeHook: Function, [method, options], -> NILL
  @public @static afterHook: Function, [method, options], -> NILL
  @public @static finallyHook: Function, [method, options], -> NILL
  @public @static errorHook: Function, [method, options], -> NILL

  @public @static initialHooks: Function, [[CLASS, NILL]], -> Array
  @public @static beforeHooks: Function, [[CLASS, NILL]], -> Array
  @public @static afterHooks: Function, [[CLASS, NILL]], -> Array
  @public @static finallyHooks: Function, [[CLASS, NILL]], -> Array
  @public @static errorHooks: Function, [[CLASS, NILL]], -> Array

  @public initialAction: Function, ANY, -> ANY
  @public beforeAction: Function, ANY, -> ANY
  @public afterAction: Function, ANY, -> ANY
  @public finallyAction: Function, ANY, -> ANY
  @public errorInAction: Function, ANY, -> ANY

  # созможно лучше реализовать в Core, чтобы в CoreObject можно было пользоваться технологией примесей
  @private @static __keywords: Array
  @public @static defineInstanceDescriptors: Function, [definitions], -> NILL
  @public @static defineClassDescriptors: Function, [definitions], -> NILL
  @public @static resetParentSuper: Function, [Function], -> Function
  @public @static include: Function, ANY, -> SELF

  # возможно можно вынести в миксин и подключать уже сам миксин.
  @public @static beforeAllEvents: Function, [String], -> NILL
  @public @static afterAllTransitions: Function, [String], -> NILL
  @public @static afterAllEvents: Function, [String], -> NILL
  @public @static errorOnAllEvents: Function, [String], -> NILL
  @public @static state: Function, [String, Object], -> NILL
  @public @static event: Function, [String, Object, lambda], -> NILL
  @public @static transition: Function, [String, String, Object], -> NILL
  @public @static StateMachine: Function, [String, Object], -> NILL

class CoreObject extends Core
  @implements CoreObjectInterface
