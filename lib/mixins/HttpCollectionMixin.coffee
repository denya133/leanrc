_             = require 'lodash'
inflect       = do require 'i'


module.exports = (Module)->
  {ANY, NILL} = Module::

  Module.defineMixin Module::Collection, (BaseClass) ->
    class HttpCollectionMixin extends BaseClass
      @inheritProtected()
      @implements Module::QueryableCollectionMixinInterface

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
            .filter '@doc.id': {$eq: id}
            .remove '@doc'
          yield @query voQuery
          return yes

      @public @async take: Function,
        default: (id)->
          voQuery = Module::Query.new()
            .forIn '@doc': @collectionFullName()
            .filter '@doc.id': {$eq: id}
            .return '@doc'
          return yield (yield @query voQuery).first()

      @public @async takeMany: Function,
        default: (ids)->
          voQuery = Module::Query.new()
            .forIn '@doc': @collectionFullName()
            .filter '@doc.id': {$in: ids}
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
            .filter '@doc.id': {$eq: id}
            .replace aoRecord
          return yield (yield @query voQuery).first()

      @public @async patch: Function,
        default: (id, aoRecord)->
          voQuery = Module::Query.new()
            .forIn '@doc': @collectionFullName()
            .filter '@doc.id': {$eq: id}
            .update aoRecord
          return yield (yield @query voQuery).first()

      @public @async includes: Function,
        default: (id)->
          voQuery = Module::Query.new()
            .forIn '@doc': @collectionFullName()
            .filter '@doc.id': {$eq: id}
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
        default: 'query'

      @public headersForRequest: Function,
        args: [Object]
        return: Object
        default: (params)->
          headers = @headers ? {}
          headers['Accept'] = 'application/json'
          headers

      @public methodForRequest: Function,
        args: [Object]
        return: String
        default: -> 'POST'

      @public dataForRequest: Function,
        args: [Object]
        return: Object
        default: ({query})-> {query}

      @public urlForRequest: Function,
        args: [Object]
        return: String
        default: (params)-> @buildURL params

      @public pathForType: Function,
        args: [String]
        return: String
        default: (recordName)->
          inflect.pluralize inflect.underscore recordName.replace /Record$/, ''

      @public urlPrefix: Function,
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

      @public buildURL: Function,
        args: [Object]
        return: String
        default: ({recordName})->
          url = []
          prefix = @urlPrefix()

          if recordName
            path = @pathForType recordName
            url.push path if path

          url.push encodeURIComponent @postfix if @postfix?
          url.unshift prefix if prefix

          url = url.join '/'
          if not @host and url and url.charAt(0) isnt '/'
            url = '/' + url

          return url

      @public requestFor: Function,
        args: [Object]
        return: Object
        default: (params)->
          method  = @methodForRequest params
          url     = @urlForRequest params
          headers = @headersForRequest params
          data    = @dataForRequest params
          return {method, url, headers, data}

      # может быть переопределно другим миксином, который будет посылать запросы через jQuery.ajax например
      @public @async sendRequest: Function,
        args: [Object]
        return: Object
        default: ({method, url, options})->
          return yield Module::Utils.request method, url, options

      # может быть переопределно другим миксином, который будет посылать запросы через jQuery.ajax например
      @public requestToHash: Function,
        args: [Object]
        return: Object
        default: ({method, url, headers, data})->
          options = {
            json: yes
            headers
          }
          options.body = data
          return {
            method
            url
            options
          }

      @public @async makeRequest: Function,
        args: [Object]
        return: Object
        default: (request)-> # result of requestFor
          {
            LogMessage: {
              SEND_TO_LOG
              LEVELS
              DEBUG
            }
          } = Module::
          hash = @requestToHash request
          @sendNotification(SEND_TO_LOG, "HttpCollectionMixin::makeRequest hash #{JSON.stringify hash}", LEVELS[DEBUG])
          return yield @sendRequest hash

      @public @async parseQuery: Function,
        default: (aoQuery)->
          voQuery = null
          switch
            when aoQuery.$remove?
              if aoQuery.$forIn?
                voQuery ?= {}
                voQuery.requestType = 'remove'
                voQuery.recordName = @delegate.name
                voQuery.query = aoQuery
                yield return voQuery
            when (voRecord = aoQuery.$insert)?
              if aoQuery.$into?
                voQuery ?= {}
                voQuery.requestType = 'insert'
                voQuery.recordName = @delegate.name
                aoQuery.$insert = yield @delegate.replicateObject voRecord
                voQuery.query = aoQuery
                yield return voQuery
            when (voRecord = aoQuery.$update)?
              if aoQuery.$forIn?
                voQuery ?= {}
                voQuery.requestType = 'update'
                voQuery.recordName = @delegate.name
                aoQuery.$update = yield @delegate.replicateObject voRecord
                voQuery.query = aoQuery
                yield return voQuery
            when (voRecord = aoQuery.$replace)?
              if aoQuery.$forIn?
                voQuery ?= {}
                voQuery.requestType = 'replace'
                voQuery.recordName = @delegate.name
                aoQuery.$replace = yield @delegate.replicateObject voRecord
                voQuery.query = aoQuery
                yield return voQuery
            else
              voQuery ?= {}
              voQuery.requestType = 'find'
              voQuery.recordName = @delegate.name
              voQuery.query = aoQuery
              voQuery.isCustomReturn = (
                aoQuery.$collect? or
                aoQuery.$count? or
                aoQuery.$sum? or
                aoQuery.$min? or
                aoQuery.$max? or
                aoQuery.$avg? or
                aoQuery.$remove? or
                aoQuery.$return isnt '@doc' and not aoQuery.$insert?
              )
              yield return voQuery

      @public @async executeQuery: Function,
        default: (aoQuery, options)->
          request = @requestFor aoQuery

          res = yield @makeRequest request
          { body } = res

          if body? and body isnt ''
            if _.isString body
              body = JSON.parse body
            unless _.isArray body
              body = [body]

            if aoQuery.isCustomReturn
              return Module::Cursor.new null, body
            else
              return Module::Cursor.new @, body


    HttpCollectionMixin.initializeMixin()
