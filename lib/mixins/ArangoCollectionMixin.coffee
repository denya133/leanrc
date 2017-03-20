# надо реализовать в отдельном модуле (npm-пакете) так как является платформозависимым
# эта реализация должна имплементировать методы `parseQuery` и `executeQuery`.
# последний должен возврашать результат с интерфейсом CursorInterface
# но для хранения и получения данных должна обращаться к ArangoDB коллекциям.

_             = require 'lodash'
{ db }        = require '@arangodb'
qb            = require 'aqb'
RC            = require 'RC'

# здесь же будем использовать ArangoCursor


module.exports = (LeanRC)->
  class LeanRC::ArangoCollectionMixin extends RC::Mixin
    @inheritProtected()

    @Module: LeanRC

    @public parseQuery: Function,
      default: (aoQuery)->
        voQuery = null
        if aoQuery.$remove?
          do =>
            if aoQuery.$forIn?
              for own asItemRef, asCollectionFullName of aoQuery.$forIn
                voQuery = (voQuery ? qb).for qb.ref asItemRef.replace '@', ''
                  .in asCollectionFullName
              if (voJoin = aoQuery.$join)?
                vlJoinFilters = voJoin.$and.map (asItemRef, {$eq:asRelValue})->
                  voItemRef = qb.ref asItemRef.replace '@', ''
                  voRelValue = qb.ref asRelValue.replace '@', ''
                  qb.eq voItemRef, voRelValue
                voQuery = voQuery.filter qb.and vlJoinFilters...
              if (voFilter = aoQuery.$filter)?
                # TODO: здесь надо что нибудь придумать потому что внутри aoQuery.$filter может быть добольно сложный объект
              if (voLet = aoQuery.$let)?
                for own asRef, aoValue of voLet
                  voQuery = (voQuery ? qb).let qb.ref(asRef.replace '@', ''), qb.expr @parseQuery LeanRC::Query.new aoValue
              voQuery = (voQuery ? qb).remove aoQuery.$remove
              if aoQuery.$into?
                voQuery = voQuery.into aoQuery.$into
        else if (voRecord = aoQuery.$insert)?
          do =>
            if aoQuery.$into?
              if aoQuery.$forIn?
                for own asItemRef, asCollectionFullName of aoQuery.$forIn
                  voQuery = (voQuery ? qb).for qb.ref asItemRef.replace '@', ''
                    .in asCollectionFullName
                if (voJoin = aoQuery.$join?.$and)?
                  vlJoinFilters = voJoin.map (asItemRef, {$eq:asRelValue})->
                    voItemRef = qb.ref asItemRef.replace '@', ''
                    voRelValue = qb.ref asRelValue.replace '@', ''
                    qb.eq voItemRef, voRelValue
                  voQuery = voQuery.filter qb.and vlJoinFilters...
                if (voFilter = aoQuery.$filter)?
                  # TODO: здесь надо что нибудь придумать потому что внутри aoQuery.$filter может быть добольно сложный объект
                if (voLet = aoQuery.$let)?
                  for own asRef, aoValue of voLet
                    voQuery = (voQuery ? qb).let qb.ref(asRef.replace '@', ''), qb.expr @parseQuery LeanRC::Query.new aoValue
              vhObjectForInsert = @serializer.serialize voRecord
              voQuery = (voQuery ? qb).insert vhObjectForInsert
                .into aoQuery.$into
        else if (voRecord = aoQuery.$update)?
          do =>
            if aoQuery.$into?
              if aoQuery.$forIn?
                for own asItemRef, asCollectionFullName of aoQuery.$forIn
                  voQuery = (voQuery ? qb).for qb.ref asItemRef.replace '@', ''
                    .in asCollectionFullName
                if (voJoin = aoQuery.$join?.$and)?
                  vlJoinFilters = voJoin.map (asItemRef, {$eq:asRelValue})->
                    voItemRef = qb.ref asItemRef.replace '@', ''
                    voRelValue = qb.ref asRelValue.replace '@', ''
                    qb.eq voItemRef, voRelValue
                  voQuery = voQuery.filter qb.and vlJoinFilters...
                if (voFilter = aoQuery.$filter)?
                  # TODO: здесь надо что нибудь придумать потому что внутри aoQuery.$filter может быть добольно сложный объект
                if (voLet = aoQuery.$let)?
                  for own asRef, aoValue of voLet
                    voQuery = (voQuery ? qb).let qb.ref(asRef.replace '@', ''), qb.expr @parseQuery LeanRC::Query.new aoValue
              vhObjectForUpdate = @serializer.serialize voRecord
              voQuery = (voQuery ? qb).update qb.ref 'doc'
                .with vhObjectForUpdate
                .into aoQuery.$into
        else if (voRecord = aoQuery.$replace)?
          do =>
            if aoQuery.$into?
              if aoQuery.$forIn?
                for own asItemRef, asCollectionFullName of aoQuery.$forIn
                  voQuery = (voQuery ? qb).for qb.ref asItemRef.replace '@', ''
                    .in asCollectionFullName
                if (voJoin = aoQuery.$join?.$and)?
                  vlJoinFilters = voJoin.map (asItemRef, {$eq:asRelValue})->
                    voItemRef = qb.ref asItemRef.replace '@', ''
                    voRelValue = qb.ref asRelValue.replace '@', ''
                    qb.eq voItemRef, voRelValue
                  voQuery = voQuery.filter qb.and vlJoinFilters...
                if (voFilter = aoQuery.$filter)?
                  # TODO: здесь надо что нибудь придумать потому что внутри aoQuery.$filter может быть добольно сложный объект
                if (voLet = aoQuery.$let)?
                  for own asRef, aoValue of voLet
                    voQuery = (voQuery ? qb).let qb.ref(asRef.replace '@', ''), qb.expr @parseQuery LeanRC::Query.new aoValue
              vhObjectForReplace = @serializer.serialize voRecord
              voQuery = (voQuery ? qb).replace qb.ref 'doc'
                .with vhObjectForReplace
                .into aoQuery.$into
        else if aoQuery.$forIn?
          do =>
            for own asItemRef, asCollectionFullName of aoQuery.$forIn
              voQuery = (voQuery ? qb).for qb.ref asItemRef.replace '@', ''
                .in asCollectionFullName
            if (voJoin = aoQuery.$join)?
              vlJoinFilters = voJoin.$and.map (asItemRef, {$eq:asRelValue})->
                voItemRef = qb.ref asItemRef.replace '@', ''
                voRelValue = qb.ref asRelValue.replace '@', ''
                qb.eq voItemRef, voRelValue
              voQuery = voQuery.filter qb.and vlJoinFilters...
            if (voFilter = aoQuery.$filter)?
              # TODO: здесь надо что нибудь придумать потому что внутри aoQuery.$filter может быть добольно сложный объект
            if (voLet = aoQuery.$let)?
              # TODO: здесь тоже может быть сложный объект
            if (voCollect = aoQuery.$collect)?
            if (voAggregate = aoQuery.$aggregate)?
            if (voHaving = aoQuery.$having)?
              # TODO: здесь надо что нибудь придумать потому что внутри aoQuery.$having может быть добольно сложный объект как в aoQuery.$filter
            if (voSort = aoQuery.$sort)?
              for own asRef, asSortDirect of aoQuery.$sort
                voQuery = voQuery.sort qb.ref(asRef.replace '@', ''), asSortDirect

            if (vnLimit = aoQuery.$limit)?
              if (vnOffset = aoQuery.$offset)?
                voQuery = voQuery.limit vnOffset, vnLimit
              else
                voQuery = voQuery.limit vnLimit

            if (aoQuery.$avg ? aoQuery.$sum ? aoQuery.$min ? aoQuery.$max ? aoQuery.$count)?

            if aoQuery.$return?
              voReturn = if _.isString aoQuery.$return
                qb.ref aoQuery.$return.replace '@', ''
              else if _.isObject aoQuery.$return
                vhObj = {}
                for own key, value of aoQuery.$return
                  do (key, value)->
                    vhObj[key] = qb.ref value.replace '@', ''
                vhObj
              if aoQuery.$distinct
                voQuery = voQuery.returnDistinct voReturn
              else
                voQuery = voQuery.return voReturn
        return voQuery.toAQL()

    @public executeQuery: Function,
      default: (aoQuery, options)->
        voNativeCursor = db._query aoQuery
        voCursor = LeanRC::ArangoCursor.new @delegate, voNativeCursor
        return voCursor


  return LeanRC::ArangoCollection.initialize()
