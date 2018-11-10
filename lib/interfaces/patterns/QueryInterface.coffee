# Здесь задекларировано как сейчас этот класс выглядит
# возможно большая часть этого останется и перейдет в финальный вариант
# Важно: в финале у инстанса не будет метода `exec` который есть сейчас, но будет метод `query` который будет вызываться извне, а в результате будет возвращатся объект с интерфейсом QueryObjectInterface , чтобы потом на основе этих данных конструировать на нужном языке запрос в базу данных


module.exports = (Module)->
  {
    FuncG, UnionG
    QueryInterface: QueryInterfaceDefinition
    Interface
  } = Module::

  class QueryInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual @static operatorsMap: Object

    @virtual $forIn: Object
    @virtual $join: Object
    @virtual $let: Object
    @virtual $filter: Object
    @virtual $collect: Object
    @virtual $into: UnionG String, Object
    @virtual $having: Object
    @virtual $sort: Array
    @virtual $limit: Number
    @virtual $offset: Number
    @virtual $avg: String # '@doc.price'
    @virtual $sum: String # '@doc.price'
    @virtual $min: String # '@doc.price'
    @virtual $max: String # '@doc.price'
    @virtual $count: Boolean # yes or not present
    @virtual $distinct: Boolean # yes or not present
    @virtual $remove: Boolean
    @virtual $patch: Object
    @virtual $return: Object

    @virtual forIn: FuncG Object, QueryInterfaceDefinition
    @virtual join: FuncG Object, QueryInterfaceDefinition
    @virtual filter: FuncG Object, QueryInterfaceDefinition
    @virtual let: FuncG Object, QueryInterfaceDefinition
    @virtual collect: FuncG Object, QueryInterfaceDefinition
    @virtual into: FuncG Object, QueryInterfaceDefinition
    @virtual having: FuncG Object, QueryInterfaceDefinition
    @virtual sort: FuncG Object, QueryInterfaceDefinition
    @virtual limit: FuncG Number, QueryInterfaceDefinition
    @virtual offset: FuncG Number, QueryInterfaceDefinition
    @virtual distinct: FuncG [], QueryInterfaceDefinition
    @virtual return: FuncG Object, QueryInterfaceDefinition
    @virtual remove: FuncG [UnionG String, Object], QueryInterfaceDefinition
    @virtual patch: FuncG Object, QueryInterfaceDefinition
    @virtual count: FuncG [], QueryInterfaceDefinition
    @virtual avg: FuncG String, QueryInterfaceDefinition
    @virtual min: FuncG String, QueryInterfaceDefinition
    @virtual max: FuncG String, QueryInterfaceDefinition
    @virtual sum: FuncG String, QueryInterfaceDefinition


    @initialize()
