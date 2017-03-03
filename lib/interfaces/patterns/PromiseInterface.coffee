{SELF, NILL, ANY} = FoxxMC::Constants

# нужен, чтобы предоставить абстракцию промиса как такового. с виртуальными методами.
# по коду будут использоваться и иметь схожее с обычными промисами апи.
# инициализироваться они будут по разному (для ноды, в декоратор будет засовываться нативный промис, а для аранги, специальный объект, предоставляемый отдельным npm-пакетом, реализация которого будет строго синхронной для совместимости с платформой arangodb)

###
A Promise is in one of these states:

pending: initial state, not fulfilled or rejected.
fulfilled: meaning that the operation completed successfully.
rejected: meaning that the operation failed.
###

class PromiseInterface extends Interface
  @public @static @virtual all: Function
  ,
    [
      iterable: Array
    ]
  , ->
    return: PromiseInterface
  @public @static @virtual reject: Function
  ,
    [
      reason: Error
    ]
  , ->
    return: PromiseInterface
  @public @static @virtual resolve: Function
  ,
    [
      value: ANY
    ]
  , ->
    return: PromiseInterface
  @public @static @virtual race: Function
  ,
    [
      iterable: Array
    ]
  , ->
    return: PromiseInterface
  @private @static @virtual 'Promise'
  @private @virtual 'promise'
  @public @virtual constructor: Function
  ,
    [
      onFulfilled: Function
    ,
      onRejected: Function
    ]
  , ->
    return: PromiseInterface
  @public @virtual catch: Function
  ,
    [
      onRejected: Function
    ]
  , ->
    return: PromiseInterface
  @public @virtual "then": Function
  ,
    [
      onFulfilled: Function
    ,
      onRejected: Function
    ]
  , ->
    return: PromiseInterface

class Promise extends CoreObject
  @implements PromiseInterface


# examle in usage
###
  # in api/ folder must be defined promise.coffee file with realy Promise class
  Test::Promise = Promise # for `nodejs`
  Test::Promise = require 'arangodb-promise' # for apps running in `arangodb`
  module.exports = Test::Promise
###

# realy promise will be wrapped in FoxxMC::Promise which will been used in app code.
