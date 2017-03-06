RC = require 'RC'

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
  $join: [
    '@doc.tomatoId': {$eq: '@tomato._key'}
    '@tomato.active': {$eq: yes}
  ]
  $filter: '@doc.active': {$eq: yes}
  $sort: '@doc.firstName': 'DESC'
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

module.exports = (LeanRC)->
  class LeanRC::Query extends RC::CoreObject
    @inheritProtected()
    @implements LeanRC::QueryInterface

    @Module: LeanRC

    # т.к. единообразный интерфейс (формат) объектов-запросов приходящих из браузера и работающих на уровне бизнес логики внутри сервера, то эти методы НЕ нужны.
    # @private parseQuery: Function, [], -> SELF
    # @private updateOptions: Function, [], -> SELF
    # @private updateConditions: Function, [], -> SELF
    # @private callCustomFilters: Function, [], -> SELF

    # @public includes: Function, [definitions], -> SELF # зависимо от объявленных в рекорде пропертей. поэтому требует передачи в квери класса рекорда. Конструирует let объявления
    # @public from: Function, [collectionName], -> SELF
    @public join: Function, [definitions], -> SELF # критерии связывания как в SQL JOIN ... ON
    @public forIn: Function, [definitions], -> Object # {in: ->}
    # @public where: Function, [conditions, [bindings, NILL]], -> SELF
    @public filter: Function, [conditions, [bindings, NILL]], -> SELF
    @public let: Function, [definition, [bindings, NILL]], -> SELF
    # @public group: Function, [definition], -> SELF
    @public collect: Function, [definition], -> SELF
    @public aggregate: Function, [definition], -> SELF
    @public into: Function, [variable], -> SELF
    @public having: Function, [conditions, [bindings, NILL]], -> SELF
    @public sort: Function, [definition], -> SELF
    @public limit: Function, [definition], -> SELF
    @public distinct: Function, [], -> SELF
    # @public select: Function, [fields], -> SELF
    # надо определить символ, который будет говорить об использовании объявленной переменной (ссылки), чтобы в случае когда должна ретюрниться простая строка, в объявлении просто не было символа. можно заиспользовать '$$'
    @public return: Function, [], -> SELF # может как в SQL но в объектном виде: {id: '$$doc._key', doc: '$$doc', name: '$$cucumber.name', price: '$$tomato.price', totalOnions: '$$totalOnions', description: 'Some item'}
    @public pluck: Function, [field], -> SELF
    @public count: Function, [], -> SELF
    # @public length: Function, [], -> SELF
    # @public average: Function, [field], -> SELF
    @public avg: Function, [field], -> SELF
    @public min: Function, [field], -> SELF
    @public max: Function, [field], -> SELF
    @public sum: Function, [field], -> SELF
    @public mergeQuery: Function,
      default: (aoQuery)->
        @query = LeanRC::QueryObject.new RC::Utils.extend {}, @query, aoQuery
        return @
    @public query: QueryObjectInterface

    constructor: ->
      super arguments...
      @query = LeanRC::QueryObject.new()


  return LeanRC::Query.initialize()
