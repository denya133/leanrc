

module.exports = (Module)->
  {
    ANY, NILL
    Collection
    Utils: { _, inflect }
  } = Module::

  Module.defineMixin Collection, (BaseClass) ->
    class ThinHttpCollectionMixin extends BaseClass
      @inheritProtected()

      @public @async push: Function,
        default: (aoRecord)->
          request = @[ipmRequestFor]
            requestType: 'create'
            recordName: @delegate.name
            snapshot: @serializer.serialize aoRecord

          { body } = yield @[ipmMakeRequest] request
          pluralKey = @collectionName()
          singularKey = inflect.singularize pluralKey
          body = (try JSON.parse body ? "{}") ? body
          yield Module::Cursor.new(@, [body[singularKey]]).first()

      @public @async remove: Function,
        default: (id)->
          request = @[ipmRequestFor]
            requestType: 'delete'
            recordName: @delegate.name
            id: id
          { body } = yield @[ipmMakeRequest] request
          yield return yes

      @public @async take: Function,
        default: (id)->
          request = @[ipmRequestFor]
            requestType: 'detail'
            recordName: @delegate.name
            id: id
          { body } = yield @[ipmMakeRequest] request
          pluralKey = @collectionName()
          singularKey = inflect.singularize pluralKey
          body = (try JSON.parse body ? "{}") ? body
          yield Module::Cursor.new(@, [body[singularKey]]).first()

      @public @async takeMany: Function,
        default: (ids)->
          records = yield ids.map (id)=>
            @take id
          yield return Module::Cursor.new @, records

      @public @async takeAll: Function,
        default: ->
          request = @[ipmRequestFor]
            requestType: 'list'
            recordName: @delegate.name

          voData = yield @[ipmMakeRequest] request
          { body } = voData
          pluralKey = @collectionName()
          body = (try JSON.parse body ? "{\"#{pluralKey}\":[]}") ? body
          yield return Module::Cursor.new @, body[pluralKey]

      @public @async override: Function,
        default: (id, aoRecord)->
          request = @[ipmRequestFor]
            requestType: 'replace'
            recordName: @delegate.name
            snapshot: @serializer.serialize aoRecord
            id: id

          { body } = yield @[ipmMakeRequest] request
          pluralKey = @collectionName()
          singularKey = inflect.singularize pluralKey
          body = (try JSON.parse body ? "{}") ? body
          yield Module::Cursor.new(@, [body[singularKey]]).first()

      @public @async patch: Function,
        default: (id, aoRecord)->
          request = @[ipmRequestFor]
            requestType: 'update'
            recordName: @delegate.name
            snapshot: @serializer.serialize aoRecord
            id: id

          { body } = yield @[ipmMakeRequest] request
          pluralKey = @collectionName()
          singularKey = inflect.singularize pluralKey
          body = (try JSON.parse body ? "{}") ? body
          yield Module::Cursor.new(@, [body[singularKey]]).first()

      @public @async includes: Function,
        default: (id)->
          record = yield @take id
          yield return record?

      @public @async length: Function,
        default: ->
          records = yield @takeAll()
          yield return records.count()

      @public headers: Object
      @public host: String,
        default: 'http://localhost'
      @public namespace: String,
        default: ''

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
        default: ({requestType})->
          switch requestType
            when 'list' then 'GET'
            when 'detail' then 'GET'
            when 'create' then 'POST'
            when 'update' then 'PATCH'
            when 'replace' then 'PUT'
            when 'delete' then 'DELETE'
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
          {recordName, snapshot, requestType, id} = params
          @buildURL recordName, snapshot, requestType, id

      @public pathForType: Function,
        args: [String]
        return: String
        default: (recordName)->
          inflect.pluralize inflect.underscore recordName.replace /Record$/, ''

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
          url.push @host if @host
          url.push @namespace if @namespace
          return url.join '/'

      ipmBuildURL = @protected buildURL: Function,
        args: [String, [Object, NILL], [Boolean, NILL]]
        return: String
        default: (recordName, id = null)->
          url = []
          prefix = @[ipmUrlPrefix]()

          if recordName
            path = @pathForType recordName
            url.push path if path

          url.push encodeURIComponent id if id?
          url.unshift prefix if prefix

          url = url.join '/'
          if not @host and url and url.charAt(0) isnt '/'
            url = '/' + url

          return url

      @public urlForFind: Function,
        args: [String, Object]
        return: String
        default: (recordName, id)->
          @[ipmBuildURL] recordName, id

      @public urlForInsert: Function,
        args: [String, Object]
        return: String
        default: (recordName)->
          @[ipmBuildURL] recordName

      @public urlForUpdate: Function,
        args: [String, Object, Object]
        return: String
        default: (recordName, id)->
          @[ipmBuildURL] recordName, id

      @public urlForReplace: Function,
        args: [String, Object, Object]
        return: String
        default: (recordName, id)->
          @[ipmBuildURL] recordName, id

      @public urlForRemove: Function,
        args: [String, Object]
        return: String
        default: (recordName, id)->
          @[ipmBuildURL] recordName, id

      @public buildURL: Function,
        args: [String, [Object, NILL], String, [Object, NILL]]
        return: String
        default: (recordName, snapshot, requestType, id)->
          switch requestType
            when 'list'
              @urlForFind recordName
            when 'detail'
              @urlForFind recordName, id
            when 'create'
              @urlForInsert recordName, snapshot
            when 'update'
              @urlForUpdate recordName, id, snapshot
            when 'replace'
              @urlForReplace recordName, id, snapshot
            when 'delete'
              @urlForRemove recordName, id
            else
              vsMethod = "urlFor#{inflect.camelize requestType}"
              @[vsMethod]? recordName, snapshot, requestType, id

      ipmRequestFor = @protected requestFor: Function,
        args: [Object]
        return: Object
        default: (params)->
          method  = @methodForRequest params
          url     = @urlForRequest params
          headers = @headersForRequest params
          data    = @dataForRequest params
          id      = params.id
          return {method, url, headers, data, id}

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
        default: ({method, url, headers, data, id})->
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
          {
            LogMessage: {
              SEND_TO_LOG
              LEVELS
              DEBUG
            }
          } = Module::
          hash = @[ipmRequestToHash] request
          @sendNotification(SEND_TO_LOG, "ThinHttpCollectionMixin::makeRequest hash #{JSON.stringify hash}", LEVELS[DEBUG])
          @[ipmSendRequest] hash


    ThinHttpCollectionMixin.initializeMixin()
