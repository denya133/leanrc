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
    @public @virtual $into: [String, Object]
    @public @virtual $having: Object
    @public @virtual $sort: Array
    @public @virtual $limit: Number
    @public @virtual $offset: Number
    @public @virtual $avg: String # '@doc.price'
    @public @virtual $sum: String # '@doc.price'
    @public @virtual $min: String # '@doc.price'
    @public @virtual $max: String # '@doc.price'
    @public @virtual $count: Boolean # yes or not present
    @public @virtual $distinct: Boolean # yes or not present
    @public @virtual $remove: Boolean
    @public @virtual $insert: Object
    @public @virtual $update: Object
    @public @virtual $replace: Object
    @public @virtual $return: [String, Object]

    @public @virtual forIn: Function,
      args: [Object] # definitions
      return: QueryInterface
    @public @virtual join: Function,
      args: [Object] # definitions
      return: QueryInterface
    @public @virtual filter: Function,
      args: [Object] # definitions
      return: QueryInterface
    @public @virtual let: Function,
      args: [Object] # definitions
      return: QueryInterface
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
    @public @virtual return: Function,
      args: [Object] # definition
      return: QueryInterface
    @public @virtual remove: Function,
      args: [[String, Object]] # definition
      return: QueryInterface
    @public @virtual insert: Function,
      args: [Object] # definition
      return: QueryInterface
    @public @virtual update: Function,
      args: [Object] # definition
      return: QueryInterface
    @public @virtual replace: Function,
      args: [Object] # definition
      return: QueryInterface
    @public @virtual count: Function,
      args: []
      return: QueryInterface
    @public @virtual avg: Function,
      args: [String] # definition
      return: QueryInterface
    @public @virtual min: Function,
      args: [String] # definition
      return: QueryInterface
    @public @virtual max: Function,
      args: [String] # definition
      return: QueryInterface
    @public @virtual sum: Function,
      args: [String] # definition
      return: QueryInterface


  return LeanRC::QueryInterface.initialize()
