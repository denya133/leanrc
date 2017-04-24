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
  {NILL, ANY} = Module::

  class Query extends Module::CoreObject
    @inheritProtected()
    @implements Module::QueryInterface

    @module Module

    @public @static operatorsMap: Object,
      default:
        $and: Array
        $or: Array
        $not: Object
        $nor: Array # not or # !(a||b) === !a && !b

        # без вложенных условий и операторов - value конечное значение для сравнения
        $eq: ANY # ==
        $ne: ANY # !=
        $lt: ANY # <
        $lte: ANY # <=
        $gt: ANY # >
        $gte: ANY # >=

        $in: Array # check value present in array
        $nin: Array # ... not present in array

        # field has array of values
        $all: Array # contains some values
        $elemMatch: Object # conditions for complex item
        $size: Number # condition for array length

        $exists: Boolean # condition for check present some value in field
        $type: String # check value type

        $mod: Array # [divisor, remainder] for example [4,0] делится ли на 4
        $regex: [RegExp, String] # value must be string. ckeck it by RegExp.

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
    # @public $aggregate: Object
    @public $into: [String, Object]
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
    @public $insert: Object
    @public $update: Object
    @public $replace: Object
    @public $return: Object

    @public forIn: Function,
      default: (aoDefinitions)->
        @$forIn ?= {}
        @$forIn = Module::Utils.extend {}, @$forIn, aoDefinitions
        return @
    @public join: Function, # критерии связывания как в SQL JOIN ... ON
      default: (aoDefinitions)->
        @$join = aoDefinitions
        return @
    @public filter: Function,
      default: (aoDefinitions)->
        @$filter = aoDefinitions
        return @
    @public let: Function,
      default: (aoDefinitions)->
        @$let ?= {}
        @$let = Module::Utils.extend {}, @$let, aoDefinitions
        return @
    @public collect: Function,
      default: (aoDefinition)->
        @$collect = aoDefinition
        return @
    @public into: Function,
      default: (aoDefinition)->
        @$into = aoDefinition
        return @
    @public having: Function,
      default: (aoDefinition)->
        @$having = aoDefinition
        return @
    @public sort: Function,
      default: (aoDefinition)->
        @$sort ?= []
        @$sort.push aoDefinition
        return @
    @public limit: Function,
      default: (anValue)->
        @$limit = anValue
        return @
    @public offset: Function,
      default: (anValue)->
        @$offset = anValue
        return @
    @public distinct: Function,
      default: ->
        @$distinct = yes
        return @
    @public remove: Function,
      default: ->
        @$remove = yes
        return @
    @public insert: Function,
      default: (aoDefinition)->
        @$insert = aoDefinition
        return @
    @public update: Function,
      default: (aoDefinition)->
        @$update = aoDefinition
        return @
    @public replace: Function,
      default: (aoDefinition)->
        @$replace = aoDefinition
        return @
    @public return: Function,
      default: (aoDefinition)->
        @$return = aoDefinition
        return @
    @public count: Function,
      default: ->
        @$count = yes
        return @
    @public avg: Function,
      default: (asDefinition)->
        @$avg = asDefinition
        return @
    @public min: Function,
      default: (asDefinition)->
        @$min = asDefinition
        return @
    @public max: Function,
      default: (asDefinition)->
        @$max = asDefinition
        return @
    @public sum: Function,
      default: (asDefinition)->
        @$sum = asDefinition
        return @

    @public init: Function,
      default: (aoQuery)->
        @super arguments...
        for own key, value of aoQuery
          do (key, value)=>
            @[key] = value


  Query.initialize()
