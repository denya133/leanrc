# можно реализовать в составе LeanRC, так как внутри для посылки http запросов будем использовать полифил из RC::Utils.request

_             = require 'lodash'
Parser        = require 'mongo-parse' #mongo-parse@2.0.2
# moment        = require 'moment'
RC            = require 'RC'

# будем использовать этот миксин для посылки запросов из ноды в арангу например.
# TODO: надо посмотреть как эту задачу решает Ember

module.exports = (LeanRC)->
  class LeanRC::HttpCollectionMixin extends RC::Mixin
    @inheritProtected()

    @Module: LeanRC

    @public method: String

    @public parseQuery: Function,
      default: (aoQuery)->
        voQuery = null
        aggUsed = aggPartial = intoUsed = intoPartial = finAggUsed = finAggPartial = null
        if aoQuery.$remove?
          do =>
            @method = 'DELETE'
            # родилась мысль - чтобы это корректно обрабатывать на HTTP уровне, надо чтобы было: (2 возможных варианта решения)
            # 1. Либо мы конвертируем половину запроса в запрос на list - чтобы отфильтровать все записи, после чего идем циклом по массиву, и на каждом итеме вызываем запрос на DELETE|>/items/:item_id/
            # 2. Либо создаем отдельный эндпоинт аналогичный list, но этот эндпоинт обрабатывает метод DELETE - т.е. запрос будет DELETE|</items/?query="<some query>"
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
                voQuery = voQuery.filter @parseFilter Parser.parse voFilter
              if (voLet = aoQuery.$let)?
                for own asRef, aoValue of voLet
                  voQuery = (voQuery ? qb).let qb.ref(asRef.replace '@', ''), qb.expr @parseQuery LeanRC::Query.new aoValue
              voQuery = (voQuery ? qb).remove aoQuery.$remove
              if aoQuery.$into?
                voQuery = voQuery.into aoQuery.$into
        else if (voRecord = aoQuery.$insert)?
          do =>
            if aoQuery.$into?
              @method = 'POST'
              # вот эту часть от $forIn и до фильтрации с летом - не пойму какой в нее вкладывал смысл - это же всетаки просто вставка новой записи в базу данных.
              # сейчас придумал один из возможных смыслов - если фильтрация возвращает результат, то вставка происходит, иначе не происходит (аналог условного оператора) - но это надо обсудить.
              # возможно это полная бессмыслица.
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
                  voQuery = voQuery.filter @parseFilter Parser.parse voFilter
                if (voLet = aoQuery.$let)?
                  for own asRef, aoValue of voLet
                    voQuery = (voQuery ? qb).let qb.ref(asRef.replace '@', ''), qb.expr @parseQuery LeanRC::Query.new aoValue
              vhObjectForInsert = @serializer.serialize voRecord
              voQuery = (voQuery ? qb).insert vhObjectForInsert
                .into aoQuery.$into
        else if (voRecord = aoQuery.$update)?
          do =>
            if aoQuery.$into?
              @method = 'PATCH'
              # квери параметры надо завернуть в url после ?, а vhObjectForUpdate передать в body
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
                  voQuery = voQuery.filter @parseFilter Parser.parse voFilter
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
              @method = 'PUT'
              # квери параметры надо завернуть в url после ?, а vhObjectForUpdate передать в body
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
                  voQuery = voQuery.filter @parseFilter Parser.parse voFilter
                if (voLet = aoQuery.$let)?
                  for own asRef, aoValue of voLet
                    voQuery = (voQuery ? qb).let qb.ref(asRef.replace '@', ''), qb.expr @parseQuery LeanRC::Query.new aoValue
              vhObjectForReplace = @serializer.serialize voRecord
              voQuery = (voQuery ? qb).replace qb.ref 'doc'
                .with vhObjectForReplace
                .into aoQuery.$into
        else if aoQuery.$forIn?
          do =>
            @method = 'GET'
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
              voQuery = voQuery.filter @parseFilter Parser.parse voFilter
            if (voLet = aoQuery.$let)?
              for own asRef, aoValue of voLet
                voQuery = (voQuery ? qb).let qb.ref(asRef.replace '@', ''), qb.expr @parseQuery LeanRC::Query.new aoValue
            if (voCollect = aoQuery.$collect)?
              for own asRef, aoValue of voCollect
                voQuery = voQuery.collect qb.ref(asRef.replace '@', ''), qb.expr @parseQuery LeanRC::Query.new aoValue
            if (voAggregate = aoQuery.$aggregate)?
              vsAggregate = (for own asRef, aoValue of voAggregate
                do (asRef, aoValue)->
                  "#{asRef.replace '@', ''} = #{aoValue}"
              ).join ', '
              aggUsed = _.escapeRegExp "FILTER {{AGGREGATE #{vsAggregate}}}"
              if aoQuery.$collect?
                aggPartial = "AGGREGATE #{vsAggregate}"
              else
                aggPartial = "COLLECT AGGREGATE #{vsAggregate}"
              voQuery = voQuery.filter qb.expr "{{AGGREGATE #{vsAggregate}}}"
            if (vsInto = aoQuery.$into)?
              intoUsed = _.escapeRegExp "FILTER {{INTO #{vsInto}}}"
              intoPartial = "INTO #{vsInto}"
              query = query.filter qb.expr "{{INTO #{vsInto}}}"
            if (voHaving = aoQuery.$having)?
              voQuery = voQuery.filter @parseFilter Parser.parse voHaving
            if (voSort = aoQuery.$sort)?
              for own asRef, asSortDirect of aoQuery.$sort
                voQuery = voQuery.sort qb.ref(asRef.replace '@', ''), asSortDirect

            if (vnLimit = aoQuery.$limit)?
              if (vnOffset = aoQuery.$offset)?
                voQuery = voQuery.limit vnOffset, vnLimit
              else
                voQuery = voQuery.limit vnLimit

            if (aoQuery.$count)?
              voQuery = voQuery.collectWithCountInto 'counter'
                .return qb.ref('counter').then('counter').else('0')
            else if (vsSum = aoQuery.$sum)?
              finAggUsed = "RETURN {{COLLECT AGGREGATE result = SUM\\(TO_NUMBER\\(#{vsSum.replace '@', ''}\\)\\) RETURN result}}"
              finAggPartial = "COLLECT AGGREGATE result = SUM(TO_NUMBER(#{vsSum.replace '@', ''})) RETURN result"
              voQuery = voQuery.return qb.expr "{{#{finAggPartial}}}"
            else if (vsMin = aoQuery.$min)?
              voQuery = voQuery.sort qb.ref(vsMin.replace '@', '')
                .limit 1
                .return qb.ref(vsMin.replace '@', '')
            else if (vsMax = aoQuery.$max)?
              voQuery = voQuery.sort qb.ref(vsMax.replace '@', ''), 'DESC'
                .limit 1
                .return qb.ref(vsMax.replace '@', '')
            else if (vsAvg = aoQuery.$avg)?
              finAggUsed = "RETURN {{COLLECT AGGREGATE result = AVG\\(TO_NUMBER\\(#{vsSum.replace '@', ''}\\)\\) RETURN result}}"
              finAggPartial = "COLLECT AGGREGATE result = AVG(TO_NUMBER(#{vsSum.replace '@', ''})) RETURN result"
              voQuery = voQuery.return qb.expr "{{#{finAggPartial}}}"
            else
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
        vsQuery = voQuery.toAQL()

        if aggUsed and new RegExp(aggUsed).test vsQuery
          vsQuery = vsQuery.replace new RegExp(aggUsed), aggPartial
        if intoUsed and new RegExp(intoUsed).test vsQuery
          vsQuery = vsQuery.replace new RegExp(intoUsed), intoPartial
        if finAggUsed and new RegExp(finAggUsed).test vsQuery
          vsQuery = vsQuery.replace new RegExp(finAggUsed), finAggPartial

        return vsQuery

    @public executeQuery: Function,
      default: (asQuery, options)->
        # здесь надо посылать платформонезависимый http запрос к нужному апи-серверу - например RC::Utils.request - полифил для ноды/аранги
        # конфиги апи сервера (урл,...) можно взять из @getData() тк. конфиги должны быть переданы при инстанцировании прокси.
        voNativeCursor = db._query asQuery
        voCursor = LeanRC::Cursor.new @delegate, voNativeCursor # вместо этого курсора надо сделать курсор на основе массива.
        return voCursor


  return LeanRC::HttpCollectionMixin.initialize()
