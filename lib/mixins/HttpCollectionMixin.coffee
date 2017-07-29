_             = require 'lodash'
inflect       = do require 'i'


module.exports = (Module)->
  {
    ANY, NILL
    APPLICATION_MEDIATOR
  } = Module::

  Module.defineMixin Module::Collection, (BaseClass) ->
    class HttpCollectionMixin extends BaseClass
      @inheritProtected()
      @implements Module::QueryableCollectionMixinInterface

      @public recordMultipleName: Function,
        default: -> @collectionName()

      @public recordSingleName: Function,
        default: -> inflect.singularize @recordMultipleName()

      @public @async push: Function,
        default: (aoRecord)->
          params = {}
          params.requestType = 'push'
          params.recordName = @delegate.name
          params.snapshot = @serialize aoRecord

          request = @requestFor params
          res = yield @makeRequest request

          if res.status >= 400
            throw new Error "
              Request failed with status #{res.status} #{res.message}
            "

          { body } = res
          if body? and body isnt ''
            voRecord = @normalize body[@recordSingleName()]
          else
            throw new Error "
              Record payload has not existed in response body.
            "
          yield return voRecord

      @public @async remove: Function,
        default: (id)->
          params = {}
          params.requestType = 'remove'
          params.recordName = @delegate.name
          params.id = id

          request = @requestFor params
          res = yield @makeRequest request

          if res.status >= 400
            throw new Error "
              Request failed with status #{res.status} #{res.message}
            "
          yield return

      @public @async take: Function,
        default: (id)->
          params = {}
          params.requestType = 'take'
          params.recordName = @delegate.name
          params.id = id

          request = @requestFor params
          res = yield @makeRequest request

          if res.status >= 400
            throw new Error "
              Request failed with status #{res.status} #{res.message}
            "

          { body } = res
          if body? and body isnt ''
            voRecord = @normalize body[@recordSingleName()]
          else
            throw new Error "
              Record payload has not existed in response body.
            "
          yield return voRecord

      @public @async takeBy: Function,
        default: (query)->
          params = {}
          params.requestType = 'takeBy'
          params.recordName = @delegate.name
          params.query = $filter: query

          request = @requestFor params
          res = yield @makeRequest request

          if res.status >= 400
            throw new Error "
              Request failed with status #{res.status} #{res.message}
            "

          { body } = res
          if body? and body isnt ''
            vhRecordsData = []
            if (vlList = body[@recordMultipleName()])?
              vhRecordsData.push vlList...
            else if (vhItem = body[@recordSingleName()])?
              vhRecordsData.push vhItem
            voCursor = Module::Cursor.new @, vhRecordsData
          else
            throw new Error "
              Record payload has not existed in response body.
            "
          yield return voCursor

      @public @async takeMany: Function,
        default: (ids)->
          params = {}
          params.requestType = 'takeBy'
          params.recordName = @delegate.name
          params.query = $filter: '@doc.id': {$in: ids}

          request = @requestFor params
          res = yield @makeRequest request

          if res.status >= 400
            throw new Error "
              Request failed with status #{res.status} #{res.message}
            "

          { body } = res
          if body? and body isnt ''
            vhRecordsData = body[@recordMultipleName()]
            voCursor = Module::Cursor.new @, vhRecordsData
          else
            throw new Error "
              Record payload has not existed in response body.
            "
          yield return voCursor

      @public @async takeAll: Function,
        default: ->
          params = {}
          params.requestType = 'takeAll'
          params.recordName = @delegate.name
          params.query = {}

          request = @requestFor params
          res = yield @makeRequest request

          if res.status >= 400
            throw new Error "
              Request failed with status #{res.status} #{res.message}
            "

          { body } = res
          if body? and body isnt ''
            vhRecordsData = body[@recordMultipleName()]
            voCursor = Module::Cursor.new @, vhRecordsData
          else
            throw new Error "
              Record payload has not existed in response body.
            "
          yield return voCursor

      @public @async override: Function,
        default: (id, aoRecord)->
          params = {}
          params.requestType = 'override'
          params.recordName = @delegate.name
          params.snapshot = @serialize aoRecord
          params.id = id

          request = @requestFor params
          res = yield @makeRequest request

          if res.status >= 400
            throw new Error "
              Request failed with status #{res.status} #{res.message}
            "

          { body } = res
          if body? and body isnt ''
            voRecord = @normalize body[@recordSingleName()]
          else
            throw new Error "
              Record payload has not existed in response body.
            "
          yield return voRecord

      @public @async includes: Function,
        default: (id)->
          voQuery =
            $forIn: '@doc': @collectionFullName()
            $filter: '@doc.id': {$eq: id}
            $limit: 1
            $return: '@doc'
          return yield (yield @query voQuery).hasNext()

      @public @async length: Function,
        default: ->
          voQuery =
            $forIn: '@doc': @collectionFullName()
            $count: yes
          return (yield (yield @query voQuery).first()).count

      @public headers: Object
      @public host: String,
        default: 'http://localhost'
      @public namespace: String,
        default: ''
      @public queryEndpoint: String,
        default: 'query'

      @public headersForRequest: Function,
        args: [Object]
        return: Object
        default: (params = {})->
          headers = @headers ? {}
          headers['Connection'] = 'keep-alive'
          headers['Accept'] = 'application/json'
          if params.requestType in ['query', 'patchBy', 'removeBy']
            headers['Authorization'] = "Bearer #{@configs.apiKey}"
          else
            if params.requestType in ['takeAll', 'takeBy']
              headers['NonLimitation'] = @configs.apiKey
            service = @facade.retrieveMediator APPLICATION_MEDIATOR
              ?.getViewComponent()
            if service?.context?
              if service.context.headers['authorization'] is "Bearer #{@configs.apiKey}"
                headers['Authorization'] = "Bearer #{@configs.apiKey}"
              else
                sessionCookie = service.context.cookies.get @configs.sessionCookie
                headers['Cookie'] = "#{@configs.sessionCookie}=#{sessionCookie}"
            else
              headers['Authorization'] = "Bearer #{@configs.apiKey}"
          headers

      @public methodForRequest: Function,
        args: [Object]
        return: String
        default: ({requestType})->
          switch requestType
            when 'query' then 'POST'
            when 'patchBy' then 'POST'
            when 'removeBy' then 'POST'
            when 'takeAll' then 'GET'
            when 'takeBy' then 'GET'
            when 'take' then 'GET'
            when 'push' then 'POST'
            when 'remove' then 'DELETE'
            when 'override' then 'PUT'
            else
              'GET'

      @public dataForRequest: Function,
        args: [Object]
        return: Object
        default: ({recordName, snapshot, requestType, query})->
          if snapshot? and requestType in ['push', 'override']
            return snapshot
          else if requestType in ['query', 'patchBy', 'removeBy']
            return {query}
          else
            return

      @public urlForRequest: Function,
        args: [Object]
        return: String
        default: (params)->
          {recordName, snapshot, id, requestType, query} = params
          @buildURL recordName, snapshot, id, requestType, query

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

      @public makeURL: Function,
        args: [String, [Object, NILL], [Boolean, NILL]]
        return: String
        default: (recordName, query, id, isQueryable)->
          url = []
          prefix = @urlPrefix()

          if recordName
            path = @pathForType recordName
            url.push path if path

          if isQueryable and @queryEndpoint?
            url.push encodeURIComponent @queryEndpoint
          url.unshift prefix if prefix

          url.push id if id?

          url = url.join '/'
          if not @host and url and url.charAt(0) isnt '/'
            url = '/' + url
          if query?
            query = encodeURIComponent JSON.stringify query ? ''
            url += "?query=#{query}"
          return url

      @public urlForQuery: Function,
        args: [String, Object]
        return: String
        default: (recordName, query)->
          @makeURL recordName, null, null, yes

      @public urlForPatchBy: Function,
        args: [String, Object]
        return: String
        default: (recordName, query)->
          @makeURL recordName, null, null, yes

      @public urlForRemoveBy: Function,
        args: [String, Object]
        return: String
        default: (recordName, query)->
          @makeURL recordName, null, null, yes

      @public urlForTakeAll: Function,
        args: [String]
        return: String
        default: (recordName, query)->
          @makeURL recordName, query, null, no

      @public urlForTakeBy: Function,
        args: [String, Object]
        return: String
        default: (recordName, query)->
          @makeURL recordName, query, null, no

      @public urlForTake: Function,
        args: [String, String]
        return: String
        default: (recordName, id)->
          @makeURL recordName, null, id, no

      @public urlForPush: Function,
        args: [String, Object]
        return: String
        default: (recordName, snapshot)->
          @makeURL recordName, null, null, no

      @public urlForRemove: Function,
        args: [String, String]
        return: String
        default: (recordName, id)->
          @makeURL recordName, null, id, no

      @public urlForOverride: Function,
        args: [String, Object, String]
        return: String
        default: (recordName, snapshot, id)->
          @makeURL recordName, null, id, no

      @public buildURL: Function,
        args: [String, [Object, NILL], String, String, [Object, NILL]]
        return: String
        default: (recordName, snapshot, id, requestType, query)->
          switch requestType
            when 'query'
              @urlForQuery recordName, query
            when 'patchBy'
              @urlForPatchBy recordName, query
            when 'removeBy'
              @urlForRemoveBy recordName, query
            when 'takeAll'
              @urlForTakeAll recordName, query
            when 'takeBy'
              @urlForTakeBy recordName, query
            when 'take'
              @urlForTake recordName, id
            when 'push'
              @urlForPush recordName, snapshot
            when 'remove'
              @urlForRemove recordName, id
            when 'override'
              @urlForOverride recordName, snapshot, id
            else
              vsMethod = "urlFor#{inflect.camelize requestType}"
              @[vsMethod]? recordName, query, snapshot, id

      @public requestFor: Function,
        args: [Object]
        return: Object
        default: (params)->
          method  = @methodForRequest params
          url     = @urlForRequest params
          headers = @headersForRequest params
          data    = @dataForRequest params
          return {method, url, headers, data}

      @public @async sendRequest: Function,
        args: [Object]
        return: Object
        default: ({method, url, options})->
          return yield Module::Utils.request method, url, options

      @public requestToHash: Function,
        args: [Object]
        return: Object
        default: ({method, url, headers, data})->
          options = {
            json: yes
            headers
          }
          options.body = data if data?
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
          params = {}
          switch
            when aoQuery.$remove?
              if aoQuery.$forIn?
                params.requestType = 'removeBy'
                params.recordName = @delegate.name
                params.query = aoQuery
                params.isCustomReturn = yes
                yield return params
            when aoQuery.$patch?
              if aoQuery.$forIn?
                params.requestType = 'patchBy'
                params.recordName = @delegate.name
                params.query = aoQuery
                params.isCustomReturn = yes
                yield return params
            else
              params.requestType = 'query'
              params.recordName = @delegate.name
              params.query = aoQuery
              params.isCustomReturn = (
                aoQuery.$collect? or
                aoQuery.$count? or
                aoQuery.$sum? or
                aoQuery.$min? or
                aoQuery.$max? or
                aoQuery.$avg? or
                aoQuery.$remove? or
                aoQuery.$return isnt '@doc'
              )
              yield return params

      @public @async executeQuery: Function,
        default: (aoQuery, options)->
          request = @requestFor aoQuery
          res = yield @makeRequest request

          if res.status >= 400
            throw new Error "
              Request failed with status #{res.status} #{res.message}
            "

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
          else
            return Module::Cursor.new null, []


    HttpCollectionMixin.initializeMixin()
