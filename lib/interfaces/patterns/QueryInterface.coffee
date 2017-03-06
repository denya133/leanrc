# Здесь задекларировано как сейчас этот класс выглядит
# возможно большая часть этого останется и перейдет в финальный вариант
# Важно: в финале у инстанса не будет метода `exec` который есть сейчас, но будет метод `query` который будет вызываться извне, а в результате будет возвращатся объект с интерфейсом QueryObjectInterface , чтобы потом на основе этих данных конструировать на нужном языке запрос в базу данных


RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::QueryInterface extends RC::Interface
    @inheritProtected()

    @Module: LeanRC

    @public @virtual includes: Function,
      args: [Array] # definitions
      return: QueryInterface
    @public @virtual from: Function,
      args: [String] # collectionName
      return: QueryInterface
    @public @virtual joins: Function,
      args: [Object] # definitions
      return: QueryInterface
    @public @virtual for: Function,
      args: [String] # definitions
      return: Object # {in: ->}
    @public @virtual where: Function,
      args: [Object, [Object, RC::Constants.NILL]] # conditions, bindings
      return: QueryInterface
    @public @virtual filter: Function,
      args: [Object, [Object, RC::Constants.NILL]] # conditions, bindings
      return: QueryInterface
    @public @virtual let: Function,
      args: [String, [Object, RC::Constants.NILL]] # definition, bindings
      return: QueryInterface
    @public @virtual group: Function,
      args: [Object] # definition
      return: QueryInterface
    @public @virtual collect: Function,
      args: [Object] # definition
      return: QueryInterface
    @public @virtual aggregate: Function,
      args: [Object] # definition
      return: QueryInterface
    @public @virtual into: Function,
      args: [String] # variable
      return: QueryInterface
    @public @virtual having: Function,
      args: [Object, [Object, RC::Constants.NILL]] # conditions, bindings
      return: QueryInterface
    @public @virtual sort: Function,
      args: [Object] # definition
      return: QueryInterface
    @public @virtual limit: Function,
      args: [Object] # definition
      return: QueryInterface
    @public @virtual distinct: Function,
      args: []
      return: QueryInterface
    @public @virtual select: Function,
      args: [Array] # fields
      return: QueryInterface
    @public @virtual return: Function,
      args: []
      return: QueryInterface
    @public @virtual pluck: Function,
      args: [String] # field
      return: QueryInterface
    @public @virtual count: Function,
      args: []
      return: QueryInterface
    @public @virtual length: Function,
      args: []
      return: QueryInterface
    @public @virtual average: Function,
      args: [String] # field
      return: QueryInterface
    @public @virtual avg: Function,
      args: [String] # field
      return: QueryInterface
    @public @virtual min: Function,
      args: [String] # field
      return: QueryInterface
    @public @virtual max: Function,
      args: [String] # field
      return: QueryInterface
    @public @virtual sum: Function,
      args: [String] # field
      return: QueryInterface
    @public @virtual mergeQuery: Function,
      args: [Object]
      return: QueryInterface # query object (from browser)
    @public @virtual query: QueryObjectInterface # query object for Collection Proxy
    # возможно есть смысл выровнять принимаемый объект из браузера и выходной объект для Collection Proxy


  return LeanRC::QueryInterface.initialize()
