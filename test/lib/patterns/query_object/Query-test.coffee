{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
Query = LeanRC::Query
{ co } = LeanRC::Utils

describe 'Query', ->
  describe '.new', ->
    it 'should create new query', ->
      expect ->
        query = Query.new()
      .to.not.throw Error
  describe '#forIn', ->
    it 'should add `FOR .. IN` equivalent statement', ->
      query = Query.new()
        .forIn
          '@cucumber': 'cucumbers'
        .forIn
          '@tomato': 'tomatos'
      expect query
      .to.eql Query.new $forIn:
        '@cucumber': 'cucumbers'
        '@tomato': 'tomatos'
  describe '#join', ->
    it 'should add `JOIN .. ON` equivalent statement', ->
      query = Query.new()
        .join
          '@doc.tomatoId': {$eq: '@tomato._key'}
          '@tomato.active': {$eq: yes}
      expect query
      .to.eql Query.new $join:
        '@doc.tomatoId': {$eq: '@tomato._key'}
        '@tomato.active': {$eq: yes}
  describe '#filter', ->
    it 'should add `FILTER`, `WHERE` equivalent statement', ->
      query = Query.new()
        .filter
          '@doc.tomatoId': {$eq: '@tomato._key'}
          '@tomato.active': {$eq: yes}
      expect query
      .to.eql Query.new $filter:
        '@doc.tomatoId': {$eq: '@tomato._key'}
        '@tomato.active': {$eq: yes}
  describe '#let', ->
    it 'should add `LET` equivalent statement', ->
      query = Query.new()
        .let
          '@user_cucumbers':
            $forIn: '@cucumber': 'cucumbers'
            $return: '@cucumber'
        .let
          '@user_tomatos':
            $forIn: '@tomato': 'tomatos'
            $return: '@tomato'
      expect query
      .to.eql Query.new $let:
        '@user_cucumbers':
          $forIn: '@cucumber': 'cucumbers'
          $return: '@cucumber'
        '@user_tomatos':
          $forIn: '@tomato': 'tomatos'
          $return: '@tomato'
  describe '#collect', ->
    it 'should add `COLLECT` equivalent statement', ->
      query = Query.new()
        .collect
          '@country': '@doc.country'
          '@city': '@doc.city'
      expect query
      .to.eql Query.new $collect:
        '@country': '@doc.country'
        '@city': '@doc.city'
  describe '#into', ->
    it 'should add `INTO` equivalent statement', ->
      query = Query.new()
        .into
          '@groups': {name: '@doc.name', isActive: '@doc.active'}
      expect query
      .to.eql Query.new $into:
        '@groups': {name: '@doc.name', isActive: '@doc.active'}
  describe '#having', ->
    it 'should add `HAVING` equivalent statement', ->
      query = Query.new()
        .having
          '@country': {$nin: ['Australia', 'Ukraine']}
      expect query
      .to.eql Query.new $having:
        '@country': {$nin: ['Australia', 'Ukraine']}
  describe '#sort', ->
    it 'should add `ORDER BY` equivalent statement', ->
      expect ->
        query = Query.new()
        query.sort '@doc.firstName': 'DESC'
        assert.deepEqual query.$sort, [ '@doc.firstName': 'DESC' ]
      .to.not.throw Error
  describe '#limit', ->
    it 'should add `LIMIT` equivalent statement', ->
      expect Query.new().limit 10
      .to.eql Query.new $limit: 10
  describe '#offset', ->
    it 'should add `OFFSET` equivalent statement', ->
      expect Query.new().offset 10
      .to.eql Query.new $offset: 10
  describe '#distinct', ->
    it 'should add `DISTINCT` equivalent statement', ->
      expect Query.new().distinct()
      .to.eql Query.new $distinct: yes
  describe '#return', ->
    it 'should add `SELECT`, `RETURN` equivalent statement', ->
      query = Query.new()
        .return
          ageGroup: '@ageGroup'
          minAge: '@minAge'
          maxAge: '@maxAge'
      expect query
      .to.eql Query.new $return:
        ageGroup: '@ageGroup'
        minAge: '@minAge'
        maxAge: '@maxAge'
  describe '#count', ->
    it 'should add `COUNT` equivalent statement', ->
      expect Query.new().count()
      .to.eql Query.new $count: yes
  describe '#avg', ->
    it 'should add `AVG` equivalent statement', ->
      expect Query.new().avg '@doc.price'
      .to.eql Query.new $avg: '@doc.price'
  describe '#avg', ->
    it 'should add `AVG`, `AVERAGE` equivalent statement', ->
      expect Query.new().avg '@doc.price'
      .to.eql Query.new $avg: '@doc.price'
  describe '#sum', ->
    it 'should add `SUM` equivalent statement', ->
      expect Query.new().sum '@doc.price'
      .to.eql Query.new $sum: '@doc.price'
  describe '#min', ->
    it 'should add `MIN` equivalent statement', ->
      expect Query.new().min '@doc.price'
      .to.eql Query.new $min: '@doc.price'
  describe '#max', ->
    it 'should add `MAX` equivalent statement', ->
      expect Query.new().max '@doc.price'
      .to.eql Query.new $max: '@doc.price'
  describe 'integral', ->
    it 'should convert methods into equivalent statement', ->
      query = Query.new()
        .forIn '@doc': 'users'
        .filter '@doc.active': {$eq: yes}
        .collect '@country': '@doc.country', '@city': '@doc.city'
        .into '@groups': {name: '@doc.name', isActive: '@doc.active'}
        .having '@country': {$nin: ['Australia', 'Ukraine']}
        .return {country: '@country', city: '@city', usersInCity: '@groups'}
      expect query
      .to.eql Query.new
        $forIn: '@doc': 'users'
        $filter: '@doc.active': {$eq: yes}
        $collect: '@country': '@doc.country', '@city': '@doc.city'
        $into: '@groups': {name: '@doc.name', isActive: '@doc.active'}
        $having: '@country': {$nin: ['Australia', 'Ukraine']}
        $return: {country: '@country', city: '@city', usersInCity: '@groups'}
  describe '.replicateObject', ->
    it 'should create replica for query', ->
      co ->
        query = Query.new()
          .forIn '@doc': 'users'
          .filter '@doc.active': {$eq: yes}
          .collect '@country': '@doc.country', '@city': '@doc.city'
          .into '@groups': {name: '@doc.name', isActive: '@doc.active'}
          .having '@country': {$nin: ['Australia', 'Ukraine']}
          .return {country: '@country', city: '@city', usersInCity: '@groups'}
        replica = yield LeanRC::Query.replicateObject query
        assert.deepEqual replica,
          type: 'instance'
          class: 'Query'
          query:
            '$forIn': '@doc': 'users'
            # '$join': undefined
            # '$let': undefined
            '$filter': '@doc.active': '$eq': yes
            '$collect': '@country': '@doc.country', '@city': '@doc.city'
            '$into': '@groups': name: '@doc.name', isActive: '@doc.active'
            '$having': '@country': '$nin': ['Australia', 'Ukraine']
            # '$sort': undefined,
            # '$limit': undefined,
            # '$offset': undefined,
            # '$avg': undefined,
            # '$sum': undefined,
            # '$min': undefined,
            # '$max': undefined,
            # '$count': undefined,
            # '$distinct': undefined,
            # '$remove': undefined,
            # '$patch': undefined
            '$return': country: '@country', city: '@city', usersInCity: '@groups'
        yield return
  describe '.restoreObject', ->
    it 'should restore query from replica', ->
      co ->
        query = yield LeanRC::Query.restoreObject LeanRC,
          type: 'instance'
          class: 'Query'
          query:
            '$forIn': '@doc': 'users'
            # '$join': undefined
            # '$let': undefined
            '$filter': '@doc.active': '$eq': yes
            '$collect': '@country': '@doc.country', '@city': '@doc.city'
            '$into': '@groups': name: '@doc.name', isActive: '@doc.active'
            '$having': '@country': '$nin': ['Australia', 'Ukraine']
            # '$sort': undefined,
            # '$limit': undefined,
            # '$offset': undefined,
            # '$avg': undefined,
            # '$sum': undefined,
            # '$min': undefined,
            # '$max': undefined,
            # '$count': undefined,
            # '$distinct': undefined,
            # '$remove': undefined,
            # '$patch': undefined,
            '$return': country: '@country', city: '@city', usersInCity: '@groups'
        assert.deepEqual query.toJSON(),
          '$forIn': '@doc': 'users'
          # '$join': undefined
          # '$let': undefined
          '$filter': '@doc.active': '$eq': yes
          '$collect': '@country': '@doc.country', '@city': '@doc.city'
          '$into': '@groups': name: '@doc.name', isActive: '@doc.active'
          '$having': '@country': '$nin': ['Australia', 'Ukraine']
          # '$sort': undefined,
          # '$limit': undefined,
          # '$offset': undefined,
          # '$avg': undefined,
          # '$sum': undefined,
          # '$min': undefined,
          # '$max': undefined,
          # '$count': undefined,
          # '$distinct': undefined,
          # '$remove': undefined,
          # '$patch': undefined,
          '$return': country: '@country', city: '@city', usersInCity: '@groups'
        yield return
