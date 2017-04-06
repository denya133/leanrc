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

    @public headers: Object
    @public host: String,
      default: ''
    @public namespace: String,
      default: ''
    @public postfix: String,
      default: 'bulk'

    @public headersForRequest: Function,
      args: [Object]
      return: Object
      default: (params)-> @headers ? {}

    @public methodForRequest: Function,
      args: [Object]
      return: String
      default: ({requestType})->
        switch requestType
          when 'find' then 'GET'
          when 'insert' then 'POST'
          when 'update' then 'PATCH'
          when 'replace' then 'PUT'
          when 'remove' then 'DELETE'
          else
            'GET'

    @public dataForRequest: Function,
      args: [Object]
      return: Object
      default: (params)->
        {store, type, snapshot, requestType, query} = params

    @public urlForRequest: Function,
      args: [Object]
      return: String
      default: (params)->
        {type, id, ids, snapshot, snapshots, requestType, query} = params

    @public pathForType: Function,
      args: [String]
      return: String
      default: (recordName)->
        inflect.pluralize inflect.underscore recordName

    ipmUrlPrefix = @protected urlPrefix: Function,
      args: [String, String]
      return: String
      default: (path, parentURL)->
        if not @host or @host is '/'
          @host = ''

        if path
          # Protocol relative url
          if /^\/\//.test(path) or /http(s)?:\/\//.test(path)
            # Do nothing, the full @host is already included.
            return path

          # Absolute path
          else if path.charAt(0) is '/'
            return "#{@host}#{path}"
          # Relative path
          else
            return "#{parentURL}/#{path}"

        # No path provided
        url = []
        if @host then url.push @host
        if @namespace then url.push @namespace
        return url.join '/'

    ipmBuildURL = @protected buildURL: Function,
      args: [String, String]
      return: String
      default: (recordName, id)->
        url = []
        prefix = @[ipmUrlPrefix]()

        if recordName
          path = @pathForType recordName
          url.push path if path

        url.push encodeURIComponent id if id
        url.unshift prefix if prefix

        url = url.join '/'
        if not @host and url and url.charAt(0) isnt '/'
          url = '/' + url

        return url

    @public urlForFind: Function,
      args: [Object]
      return: String
      default: ()->
        this._buildURL(recordName, query)

    @public urlForInsert: Function,
      args: [Object]
      return: String
      default: ()->
        this._buildURL(recordName, query)

    @public urlForUpdate: Function,
      args: [Object]
      return: String
      default: ()->
        this._buildURL(recordName, query)

    @public urlForReplace: Function,
      args: [Object]
      return: String
      default: ()->
        this._buildURL(recordName, query)

    @public urlForRemove: Function,
      args: [Object]
      return: String
      default: (recordName, id, query)->
        this._buildURL(recordName, query)

    @public buildURL: Function,
      args: [Object]
      return: String
      default: (recordName, id, query, requestType)->
        switch requestType
          when 'find'
            @urlForFind recordName, id, query
          when 'insert'
            @urlForInsert recordName, id
          when 'update'
            @urlForUpdate recordName, id, query
          when 'replace'
            @urlForReplace recordName, id, query
          when 'remove'
            @urlForRemove recordName, id, query
          else
            @[ipmBuildURL] recordName, id

    ipmRequestFor = @protected requestFor: Function,
      args: [Object]
      return: Object
      default: (params)->
        method =  @methodForRequest params
        url =     @urlForRequest params
        headers = @headersForRequest params
        data =    @dataForRequest params
        return {method, url, headers, data}

    ipmMakeRequest = @protected makeRequest: Function,
      args: [Object]
      return: Object
      default: (request)-> # result of requestFor
        {method, url, headers, data} = request

    ipmSendRequest = @protected sendRequest: Function,
      args: [Object]
      return: Object
      default: (request)-> # call from ipmMakeRequest

    @public push: Function,
      default: (aoRecord)->
        # здесь надо придумать реальный посыл запроса к серверу
        return yes

    @public remove: Function,
      default: (query)->
        # здесь надо придумать реальный посыл запроса к серверу
        return yes

    @public take: Function,
      default: (query)->
        # здесь надо придумать реальный посыл запроса к серверу
        return result # курсор с результатами

    @public override: Function,
      default: (query, aoRecord)->
        # здесь надо придумать реальный посыл запроса к серверу
        return result # курсор с результатами

    @public patch: Function,
      default: (query, aoRecord)->
        # здесь надо придумать реальный посыл запроса к серверу
        return result # курсор с результатами





    @public forEach: Function,
      default: (lambda)->
        throw new Error 'Not available for HTTP requests'

    @public filter: Function,
      default: (lambda)->
        throw new Error 'Not available for HTTP requests'

    @public map: Function,
      default: (lambda)->
        throw new Error 'Not available for HTTP requests'

    @public reduce: Function,
      default: (lambda, initialValue)->
        throw new Error 'Not available for HTTP requests'

    ####### ПОД ВОПРОСОМ КАК ИХ АДАПТИРОВАТЬ ДЛЯ HTTP
    @public includes: Function,
      default: (id)->
        voQuery = LeanRC::Query.new()
          .forIn '@doc': @collectionFullName()
          .filter '@doc._key': {$eq: id}
          .limit 1
          .return '@doc'
        return @query voQuery
          .hasNext()

    @public exists: Function,
      default: (query)->
        voQuery = LeanRC::Query.new()
          .forIn '@doc': @collectionFullName()
          .filter query
          .limit 1
          .return '@doc'
        return @query voQuery
          .hasNext()

    @public length: Function, # количество объектов в коллекции
      default: ->
        voQuery = LeanRC::Query.new()
          .forIn '@doc': @collectionFullName()
          .count()
        return @query voQuery
          .first()
    ####### -----------------------------------------

    @public query: Function,
      default: (aoQuery)->
        throw new Error 'Not available for HTTP requests'
    @public parseQuery: Function,
      default: (aoQuery)->
        throw new Error 'Not available for HTTP requests'
    @public executeQuery: Function,
      default: (aoQuery, options)->
        throw new Error 'Not available for HTTP requests'








    @public parseQuery: Function,
      default: (aoQuery)->
        voQuery = null
        # aggUsed = aggPartial = intoUsed = intoPartial = finAggUsed = finAggPartial = null
        if aoQuery.$remove?
          do =>
            if aoQuery.$forIn?
              voQuery ?= {}
              voQuery.requestType = 'remove'
              voQuery.recordName = @delegate.name
              voQuery.query = _.pick [
                '$forIn', '$join', '$filter', '$let'
              ]
              voQuery.query.$return = '@doc'
              voQuery

            # if aoQuery.$forIn?
            #   for own asItemRef, asCollectionFullName of aoQuery.$forIn
            #     voQuery = (voQuery ? qb).for qb.ref asItemRef.replace '@', ''
            #       .in asCollectionFullName
            #   if (voJoin = aoQuery.$join)?
            #     vlJoinFilters = voJoin.$and.map (asItemRef, {$eq:asRelValue})->
            #       voItemRef = qb.ref asItemRef.replace '@', ''
            #       voRelValue = qb.ref asRelValue.replace '@', ''
            #       qb.eq voItemRef, voRelValue
            #     voQuery = voQuery.filter qb.and vlJoinFilters...
            #   if (voFilter = aoQuery.$filter)?
            #     voQuery = voQuery.filter @parseFilter Parser.parse voFilter
            #   if (voLet = aoQuery.$let)?
            #     for own asRef, aoValue of voLet
            #       voQuery = (voQuery ? qb).let qb.ref(asRef.replace '@', ''), qb.expr @parseQuery LeanRC::Query.new aoValue
            #   voQuery = (voQuery ? qb).remove aoQuery.$remove
            #   if aoQuery.$into?
            #     voQuery = voQuery.into aoQuery.$into
        else if (voRecord = aoQuery.$insert)?
          do =>
            if aoQuery.$into?
              voQuery ?= {}
              voQuery.requestType = 'insert'
              voQuery.recordName = @delegate.name
              voQuery.snapshot =
              voQuery.snapshot = _.pick [
                '$forIn', '$join', '$filter', '$let', '$remove', '$into'
              ]
              voQuery

              # vhObjectForInsert = @serializer.serialize voRecord
              # voQuery = (voQuery ? qb).insert vhObjectForInsert
              #   .into aoQuery.$into
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
      default: (aoQuery, options)->
        # здесь надо посылать платформонезависимый http запрос к нужному апи-серверу - например RC::Utils.request - полифил для ноды/аранги
        # конфиги апи сервера (урл,...) можно взять из @getData() тк. конфиги должны быть переданы при инстанцировании прокси.

        # request = @[ipmRequestFor]({
        #   store, type, id, snapshot,
        #   requestType: 'remove'
        # });
        request = @[ipmRequestFor] aoQuery

        resultItems = @[ipmMakeRequest] request
        voCursor = LeanRC::Cursor.new @delegate, resultItems # вместо этого курсора надо сделать курсор на основе массива.
        return voCursor


  return LeanRC::HttpCollectionMixin.initialize()
