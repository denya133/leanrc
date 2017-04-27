_             = require 'lodash'
inflect       = do require 'i'


module.exports = (Module)->
  {ANY, NILL} = Module::

  Module.defineMixin 'HttpCollectionMixin', (BaseClass) ->
    class HttpCollectionMixin extends BaseClass
      @inheritProtected()
      @implements Module::QueryableMixinInterface

      @module Module

      @public @async push: Function,
        default: (aoRecord)->
          voQuery = Module::Query.new()
            .insert aoRecord
            .into @collectionFullName()
          response = yield @query voQuery
          first = yield response.next()
          return first

      @public @async remove: Function,
        default: (id)->
          voQuery = Module::Query.new()
            .forIn '@doc': @collectionFullName()
            .filter '@doc._key': {$eq: id}
            .remove()
          yield @query voQuery
          return yes

      @public @async take: Function,
        default: (id)->
          voQuery = Module::Query.new()
            .forIn '@doc': @collectionFullName()
            .filter '@doc._key': {$eq: id}
            .return '@doc'
          return yield (yield @query voQuery).first()

      @public @async takeMany: Function,
        default: (ids)->
          voQuery = Module::Query.new()
            .forIn '@doc': @collectionFullName()
            .filter '@doc._key': {$in: ids}
            .return '@doc'
          return yield @query voQuery

      @public @async takeAll: Function,
        default: ->
          voQuery = Module::Query.new()
            .forIn '@doc': @collectionFullName()
            .return '@doc'
          return yield @query voQuery

      @public @async override: Function,
        default: (id, aoRecord)->
          voQuery = Module::Query.new()
            .forIn '@doc': @collectionFullName()
            .filter '@doc._key': {$eq: id}
            .replace aoRecord
          return yield (yield @query voQuery).first()

      @public @async patch: Function,
        default: (id, aoRecord)->
          voQuery = Module::Query.new()
            .forIn '@doc': @collectionFullName()
            .filter '@doc._key': {$eq: id}
            .update aoRecord
          return yield (yield @query voQuery).first()

      @public @async includes: Function,
        default: (id)->
          voQuery = Module::Query.new()
            .forIn '@doc': @collectionFullName()
            .filter '@doc._key': {$eq: id}
            .limit 1
            .return '@doc'
          return yield (yield @query voQuery).hasNext()

      @public @async length: Function,
        default: ->
          voQuery = Module::Query.new()
            .forIn '@doc': @collectionFullName()
            .count()
          return yield (yield @query voQuery).first()

      @public headers: Object
      @public host: String,
        default: 'http://localhost'
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
        default: ({snapshot})->
          return snapshot

      @public urlForRequest: Function,
        args: [Object]
        return: String
        default: (params)->
          {recordName, snapshot, requestType, query} = params
          @buildURL recordName, snapshot, requestType, query

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
        args: [String, [Object, NILL], [Boolean, NILL]]
        return: String
        default: (recordName, query, withPostfix=yes)->
          url = []
          prefix = @[ipmUrlPrefix]()

          if recordName
            path = @pathForType recordName
            url.push path if path

          url.push encodeURIComponent @postfix if withPostfix and @postfix?
          url.unshift prefix if prefix

          url = url.join '/'
          if not @host and url and url.charAt(0) isnt '/'
            url = '/' + url

          return url

      @public urlForFind: Function,
        args: [String, Object]
        return: String
        default: (recordName, query)->
          @[ipmBuildURL] recordName, query, no

      @public urlForInsert: Function,
        args: [String, Object]
        return: String
        default: (recordName)->
          @[ipmBuildURL] recordName, null, no

      @public urlForUpdate: Function,
        args: [String, Object, Object]
        return: String
        default: (recordName, query)->
          @[ipmBuildURL] recordName, query

      @public urlForReplace: Function,
        args: [String, Object, Object]
        return: String
        default: (recordName, query)->
          @[ipmBuildURL] recordName, query

      @public urlForRemove: Function,
        args: [String, Object]
        return: String
        default: (recordName, query)->
          @[ipmBuildURL] recordName, query

      @public buildURL: Function,
        args: [String, [Object, NILL], String, [Object, NILL]]
        return: String
        default: (recordName, snapshot, requestType, query)->
          switch requestType
            when 'find'
              @urlForFind recordName, query
            when 'insert'
              @urlForInsert recordName, snapshot
            when 'update'
              @urlForUpdate recordName, query, snapshot
            when 'replace'
              @urlForReplace recordName, query, snapshot
            when 'remove'
              @urlForRemove recordName, query
            else
              vsMethod = "urlFor#{inflect.camelize requestType}"
              @[vsMethod]? recordName, snapshot, requestType, query

      ipmRequestFor = @protected requestFor: Function,
        args: [Object]
        return: Object
        default: (params)->
          method  = @methodForRequest params
          url     = @urlForRequest params
          headers = @headersForRequest params
          data    = @dataForRequest params
          query   = params.query
          return {method, url, headers, data, query}

      # может быть переопределно другим миксином, который будет посылать запросы через jQuery.ajax например
      ipmSendRequest = @protected sendRequest: Function,
        args: [Object]
        return: Module::PromiseInterface
        default: ({method, url, options})->
          Module::Utils.request method, url, options

      # может быть переопределно другим миксином, который будет посылать запросы через jQuery.ajax например
      ipmRequestToHash = @protected requestToHash: Function,
        args: [Object]
        return: Object
        default: ({method, url, headers, data, query})->
          if query?
            query = JSON.stringify { query }
            url += "?query=#{query}"
          {
            method
            url
            options: {
              body: data
              json: yes
              headers
            }
          }

      ipmMakeRequest = @protected makeRequest: Function,
        args: [Object]
        return: Module::PromiseInterface
        default: (request)-> # result of requestFor
          hash = @[ipmRequestToHash] request
          @[ipmSendRequest] hash

      @public parseQuery: Function,
        default: (aoQuery)->
          voQuery = null
          if aoQuery.$remove?
            do =>
              if aoQuery.$forIn?
                voQuery ?= {}
                voQuery.requestType = 'remove'
                voQuery.recordName = @delegate.name
                voQuery.query = _.pick aoQuery, [
                  '$forIn', '$join', '$filter', '$let'
                ]
                voQuery.query.$return = '@doc'
                voQuery
          else if (voRecord = aoQuery.$insert)?
            do =>
              if aoQuery.$into?
                voQuery ?= {}
                voQuery.requestType = 'insert'
                voQuery.recordName = @delegate.name
                voQuery.snapshot = @serializer.serialize voRecord
                voQuery
          else if (voRecord = aoQuery.$update)?
            do =>
              if aoQuery.$forIn?
                voQuery ?= {}
                voQuery.requestType = 'update'
                voQuery.recordName = @delegate.name
                voQuery.snapshot = @serializer.serialize voRecord
                voQuery.query = _.pick aoQuery, [
                  '$forIn', '$join', '$filter', '$let'
                ]
                voQuery.query.$return = '@doc'
                voQuery
          else if (voRecord = aoQuery.$replace)?
            do =>
              if aoQuery.$forIn?
                voQuery ?= {}
                voQuery.requestType = 'replace'
                voQuery.recordName = @delegate.name
                voQuery.snapshot = @serializer.serialize voRecord
                voQuery.query = _.pick aoQuery, [
                  '$forIn', '$join', '$filter', '$let'
                ]
                voQuery.query.$return = '@doc'
                voQuery
          else if aoQuery.$forIn?
            do =>
              voQuery ?= {}
              voQuery.requestType = 'find'
              voQuery.recordName = @delegate.name
              voQuery.query = aoQuery
              voQuery

          return voQuery

      @public executeQuery: Function,
        default: (aoQuery, options)->
          request = @[ipmRequestFor] aoQuery

          { body } = yield @[ipmMakeRequest] request

          items = []

          if body?
            if aoQuery.query?['$count']
              items.push body.count
            else
              pluralKey = @collectionName()
              if _.isArray snapshots = body[pluralKey]
                items.push snapshots...
              else
                singularKey = inflect.singularize pluralKey
                unless _.isArray snapshot = body[singularKey]
                  items.push snapshot

          voCursor = Module::Cursor.new @, items
          return voCursor


    HttpCollectionMixin.initializeMixin()
