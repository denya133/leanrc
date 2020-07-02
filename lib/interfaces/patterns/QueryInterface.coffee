# This file is part of LeanRC.
#
# LeanRC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# LeanRC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with LeanRC.  If not, see <https://www.gnu.org/licenses/>.

# Здесь задекларировано как сейчас этот класс выглядит
# возможно большая часть этого останется и перейдет в финальный вариант
# Важно: в финале у инстанса не будет метода `exec` который есть сейчас, но будет метод `query` который будет вызываться извне, а в результате будет возвращатся объект с интерфейсом QueryObjectInterface , чтобы потом на основе этих данных конструировать на нужном языке запрос в базу данных

module.exports = (Module)->
  {
    FuncG, UnionG, MaybeG
    QueryInterface: QueryInterfaceDefinition
    Interface
  } = Module::

  class QueryInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual @static operatorsMap: Object

    @virtual $forIn: MaybeG Object
    @virtual $join: MaybeG Object
    @virtual $let: MaybeG Object
    @virtual $filter: MaybeG Object
    @virtual $collect: MaybeG Object
    @virtual $into: MaybeG UnionG String, Object
    @virtual $having: MaybeG Object
    @virtual $sort: MaybeG Array
    @virtual $limit: MaybeG Number
    @virtual $offset: MaybeG Number
    @virtual $avg: MaybeG String # '@doc.price'
    @virtual $sum: MaybeG String # '@doc.price'
    @virtual $min: MaybeG String # '@doc.price'
    @virtual $max: MaybeG String # '@doc.price'
    @virtual $count: MaybeG Boolean # yes or not present
    @virtual $distinct: MaybeG Boolean # yes or not present
    @virtual $remove: MaybeG UnionG String, Object
    @virtual $patch: MaybeG Object
    @virtual $return: MaybeG UnionG String, Object

    @virtual forIn: FuncG Object, QueryInterfaceDefinition
    @virtual join: FuncG Object, QueryInterfaceDefinition
    @virtual filter: FuncG Object, QueryInterfaceDefinition
    @virtual let: FuncG Object, QueryInterfaceDefinition
    @virtual collect: FuncG Object, QueryInterfaceDefinition
    @virtual into: FuncG [UnionG String, Object], QueryInterfaceDefinition
    @virtual having: FuncG Object, QueryInterfaceDefinition
    @virtual sort: FuncG Object, QueryInterfaceDefinition
    @virtual limit: FuncG Number, QueryInterfaceDefinition
    @virtual offset: FuncG Number, QueryInterfaceDefinition
    @virtual distinct: FuncG [], QueryInterfaceDefinition
    @virtual return: FuncG [UnionG String, Object], QueryInterfaceDefinition
    @virtual remove: FuncG [UnionG String, Object], QueryInterfaceDefinition
    @virtual patch: FuncG Object, QueryInterfaceDefinition
    @virtual count: FuncG [], QueryInterfaceDefinition
    @virtual avg: FuncG String, QueryInterfaceDefinition
    @virtual min: FuncG String, QueryInterfaceDefinition
    @virtual max: FuncG String, QueryInterfaceDefinition
    @virtual sum: FuncG String, QueryInterfaceDefinition


    @initialize()
