# Здесь задекларировано как сейчас этот класс выглядит
# возможно большая часть этого останется и перейдет в финальный вариант
# Важно: в финале у инстанса не будет метода `exec` который есть сейчас, но будет метод `query` который будет вызываться извне, а в результате будет возвращатся объект с интерфейсом QueryObjectInterface , чтобы потом на основе этих данных конструировать на нужном языке запрос в базу данных


RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::QueryInterface extends RC::Interface
    @inheritProtected()

    @Module: LeanRC

    @public @static @virtual operatorsMap: Object

    @public @virtual $forIn: Object
    @public @virtual $join: Object
    @public @virtual $let: Object
    @public @virtual $filter: Object
    @public @virtual $collect: Object
    @public @virtual $aggregate: Object
    @public @virtual $into: Object
    @public @virtual $having: Object
    @public @virtual $sort: Object
    @public @virtual $limit: Number
    @public @virtual $offset: Number
    @public @virtual $avg: String # '@doc.price'
    @public @virtual $sum: String # '@doc.price'
    @public @virtual $min: String # '@doc.price'
    @public @virtual $max: String # '@doc.price'
    @public @virtual $count: Boolean # yes or not present
    @public @virtual $distinct: Boolean # yes or not present
    @public @virtual $return: Object

    # @public @virtual includes: Function,
    #   args: [Array] # definitions
    #   return: QueryInterface
    # @public @virtual from: Function,
    #   args: [String] # collectionName
    #   return: QueryInterface
    @public @virtual forIn: Function,
      args: [Object] # definitions
      return: QueryInterface
    @public @virtual join: Function,
      args: [Object] # definitions
      return: QueryInterface
    # @public @virtual where: Function,
    #   args: [Object, [Object, RC::Constants.NILL]] # conditions, bindings
    #   return: QueryInterface
    @public @virtual filter: Function,
      args: [Object] # definitions
      return: QueryInterface
    @public @virtual let: Function,
      args: [Object] # definitions
      return: QueryInterface
    # @public @virtual group: Function,
    #   args: [Object] # definition
    #   return: QueryInterface
    @public @virtual collect: Function,
      args: [Object] # definition
      return: QueryInterface
    @public @virtual aggregate: Function,
      args: [Object] # definition
      return: QueryInterface
    @public @virtual into: Function,
      args: [Object] # definition
      return: QueryInterface
    @public @virtual having: Function,
      args: [Object] # definitions
      return: QueryInterface
    @public @virtual sort: Function,
      args: [Object] # definition
      return: QueryInterface
    @public @virtual limit: Function,
      args: [Number] # value
      return: QueryInterface
    @public @virtual offset: Function,
      args: [Number] # value
      return: QueryInterface
    @public @virtual distinct: Function,
      args: []
      return: QueryInterface
    # @public @virtual select: Function,
    #   args: [Array] # fields
    #   return: QueryInterface
    @public @virtual return: Function,
      args: [Object]
      return: QueryInterface
    # @public @virtual pluck: Function,
    #   args: [String] # field
    #   return: QueryInterface
    @public @virtual count: Function,
      args: []
      return: QueryInterface
    # @public @virtual length: Function,
    #   args: []
    #   return: QueryInterface
    # @public @virtual average: Function,
    #   args: [String] # field
    #   return: QueryInterface
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
    # @public @virtual mergeQuery: Function,
    #   args: [Object]
    #   return: QueryInterface # query object (from browser)
    # @public @virtual query: QueryObjectInterface # query object for Collection Proxy
    # возможно есть смысл выровнять принимаемый объект из браузера и выходной объект для Collection Proxy


  return LeanRC::QueryInterface.initialize()
