

###
в Ember app это может выглядить так.
```coffee
cucumber = {id: 123}
@store.query 'user',
  $and: [
    '@doc.cucumberId': {$eq: cucumber.id}
    '@doc.price': {$gt: 85}
  ]
```
###

# надо определить символ, который будет говорить об использовании объявленной переменной (ссылки), чтобы в случае когда должна ретюрниться простая строка, в объявлении просто не было символа. можно заиспользовать '@'

###
example

```coffee
new Query()
  .forIn '@doc': 'users'
  .forIn '@tomato': 'tomatos'
  .let
    '@user_cucumbers':
      $forIn: '@cucumber': 'cucumbers'
      $filter:
        $and: [
          '@doc.cucumberId': {$eq: '@cucumber._key'}
          '@cucumber.price': {$gt: 85}
        ]
      $return: '@cucumber'
  .join
    '@doc.tomatoId': {$eq: '@tomato._key'}
    '@tomato.active': {$eq: yes}
  .filter '@doc.active': {$eq: yes}
  .sort '@doc.firstName': 'DESC'
  .limit 10
  .offset 10
  .return {user: '@user', cucumbers: '@user_cucumbers', tomato: '@tomato'}
```

But it equvalent json
```
{
  $forIn: '@doc': 'users', '@tomato': 'tomatos'
  $let:
    '@user_cucumbers':
      $forIn: '@cucumber': 'cucumbers'
      $filter:
        $and: [
          '@doc.cucumberId': {$eq: '@cucumber._key'}
          '@cucumber.price': {$gt: 85}
        ]
       $return: '@cucumber'
  $join: $and: [
    '@doc.tomatoId': {$eq: '@tomato._key'}
    '@tomato.active': {$eq: yes}
  ]
  $filter: '@doc.active': {$eq: yes}
  $sort: ['@doc.firstName': 'DESC']
  $limit: 10
  $offset: 10
  $return: {user: '@user', cucumbers: '@user_cucumbers', tomato: '@tomato'}
}
```

example for collect
```
{
  $forIn: '@doc': 'users'
  $filter: '@doc.active': {$eq: yes}
  $collect: '@country': '@doc.country', '@city': '@doc.city'
  $into: '@groups': {name: '@doc.name', isActive: '@doc.active'}
  $having: '@country': {$nin: ['Australia', 'Ukraine']}
  $return: {country: '@country', city: '@city', usersInCity: '@groups'}
}

# or

{
  $forIn: '@doc': 'users'
  $filter: '@doc.active': {$eq: yes}
  $collect: '@ageGroup': 'FLOOR(@doc.age / 5) * 5'
  $aggregate: '@minAge': 'MIN(@doc.age)', '@maxAge': 'MAX(@doc.age)'
  $return: {ageGroup: '@ageGroup', minAge: '@minAge', maxAge: '@maxAge'}
}
```
###

module.exports = (Module)->
  {
    AnyT, NilT
    FuncG, SubsetG, UnionG
    QueryInterface
    CoreObject
    Utils: { _, extend }
  } = Module::

  class Query extends CoreObject
    @inheritProtected()
    @implements QueryInterface
    @module Module

    # TODO: это надо переделать на нормальную проверку типа в $filter
    @public @static operatorsMap: Object,
      default:
        $and: Array
        $or: Array
        $not: Object
        $nor: Array # not or # !(a||b) === !a && !b

        # без вложенных условий и операторов - value конечное значение для сравнения
        $eq: AnyT # ==
        $ne: AnyT # !=
        $lt: AnyT # <
        $lte: AnyT # <=
        $gt: AnyT # >
        $gte: AnyT # >=

        $in: Array # check value present in array
        $nin: Array # ... not present in array

        # field has array of values
        $all: Array # contains some values
        $elemMatch: Object # conditions for complex item
        $size: Number # condition for array length

        $exists: Boolean # condition for check present some value in field
        $type: String # check value type

        $mod: Array # [divisor, remainder] for example [4,0] делится ли на 4
        $regex: UnionG RegExp, String # value must be string. ckeck it by RegExp.

        $td: Boolean # this day (today)
        $ld: Boolean # last day (yesterday)
        $tw: Boolean # this week
        $lw: Boolean # last week
        $tm: Boolean # this month
        $lm: Boolean # last month
        $ty: Boolean # this year
        $ly: Boolean # last year

    @public $forIn: Object
    @public $join: Object
    @public $let: Object
    @public $filter: Object
    @public $collect: Object
    @public $into: UnionG String, Object
    @public $having: Object
    @public $sort: Array
    @public $limit: Number
    @public $offset: Number
    @public $avg: String # '@doc.price'
    @public $sum: String # '@doc.price'
    @public $min: String # '@doc.price'
    @public $max: String # '@doc.price'
    @public $count: Boolean # yes or not present
    @public $distinct: Boolean # yes or not present
    @public $remove: Boolean
    @public $patch: Object
    @public $return: Object

    @public forIn: FuncG(Object, QueryInterface),
      default: (aoDefinitions)->
        @$forIn ?= {}
        @$forIn = extend {}, @$forIn, aoDefinitions
        return @
    @public join: FuncG(Object, QueryInterface), # критерии связывания как в SQL JOIN ... ON
      default: (aoDefinitions)->
        @$join = aoDefinitions
        return @
    @public filter: FuncG(Object, QueryInterface),
      default: (aoDefinitions)->
        @$filter = aoDefinitions
        return @
    @public let: FuncG(Object, QueryInterface),
      default: (aoDefinitions)->
        @$let ?= {}
        @$let = extend {}, @$let, aoDefinitions
        return @
    @public collect: FuncG(Object, QueryInterface),
      default: (aoDefinition)->
        @$collect = aoDefinition
        return @
    @public into: FuncG(Object, QueryInterface),
      default: (aoDefinition)->
        @$into = aoDefinition
        return @
    @public having: FuncG(Object, QueryInterface),
      default: (aoDefinition)->
        @$having = aoDefinition
        return @
    @public sort: FuncG(Object, QueryInterface),
      default: (aoDefinition)->
        @$sort ?= []
        @$sort.push aoDefinition
        return @
    @public limit: FuncG(Number, QueryInterface),
      default: (anValue)->
        @$limit = anValue
        return @
    @public offset: FuncG(Number, QueryInterface),
      default: (anValue)->
        @$offset = anValue
        return @
    @public distinct: FuncG([], QueryInterface),
      default: ->
        @$distinct = yes
        return @
    @public remove: FuncG([UnionG String, Object], QueryInterface),
      default: (expr = yes)->
        @$remove = expr
        return @
    @public patch: FuncG(Object, QueryInterface),
      default: (aoDefinition)->
        @$patch = aoDefinition
        return @
    @public return: FuncG(Object, QueryInterface),
      default: (aoDefinition)->
        @$return = aoDefinition
        return @
    @public count: FuncG([], QueryInterface),
      default: ->
        @$count = yes
        return @
    @public avg: FuncG(String, QueryInterface),
      default: (asDefinition)->
        @$avg = asDefinition
        return @
    @public min: FuncG(String, QueryInterface),
      default: (asDefinition)->
        @$min = asDefinition
        return @
    @public max: FuncG(String, QueryInterface),
      default: (asDefinition)->
        @$max = asDefinition
        return @
    @public sum: FuncG(String, QueryInterface),
      default: (asDefinition)->
        @$sum = asDefinition
        return @

    @public @static @async restoreObject: FuncG([SubsetG(Module), Object], QueryInterface),
      default: (_Module, replica)->
        if replica?.class is @name and replica?.type is 'instance'
          instance = @new replica.query
          yield return instance
        else
          return yield @super _Module, replica

    @public @static @async replicateObject: FuncG(QueryInterface, Object),
      default: (instance)->
        replica = yield @super instance
        replica.query = instance.toJSON()
        yield return replica

    @public init: FuncG(Object, NilT),
      default: (aoQuery)->
        @super arguments...
        for own key, value of aoQuery
          do (key, value)=>
            @[key] = value
        return

    @public toJSON: FuncG([], Object),
      default: ->
        _.pick @, [
          '$forIn', '$join', '$let', '$filter', '$collect', '$into', '$having'
          '$sort', '$limit', '$offset', '$avg', '$sum', '$min', '$max', '$count'
          '$distinct', '$remove', '$patch', '$return'
        ]


    @initialize()
