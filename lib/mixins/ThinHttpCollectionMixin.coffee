

module.exports = (Module)->
  {
    AnyT, NilT, PointerT
    FuncG, MaybeG, UnionG, ListG, DictG, StructG, EnumG, InterfaceG
    RecordInterface, QueryInterface, CursorInterface
    Collection, Cursor, Mixin
    Utils: { _, inflect, request }
  } = Module::

  Module.defineMixin Mixin 'ThinHttpCollectionMixin', (BaseClass = Collection) ->
    class extends BaseClass
      @inheritProtected()

      ipsRecordMultipleName = PointerT @private recordMultipleName: MaybeG String
      ipsRecordSingleName = PointerT @private recordSingleName: MaybeG String

      @public recordMultipleName: FuncG([], String),
        default: ->
          @[ipsRecordMultipleName] ?= inflect.pluralize @recordSingleName()

      @public recordSingleName: FuncG([], String),
        default: ->
          @[ipsRecordSingleName] ?= inflect.underscore @delegate.name.replace /Record$/, ''

      @public @async push: FuncG(RecordInterface, RecordInterface),
        default: (aoRecord)->
          requestObj = @requestFor(
            requestType: 'push'
            recordName: @delegate.name
            snapshot: yield @serialize aoRecord
          )

          res = yield @makeRequest requestObj

          if res.status >= 400
            throw new Error "
              Request failed with status #{res.status} #{res.message}
            "

          { body } = res
          if body? and body isnt ''
            body = JSON.parse body if _.isString body
            voRecord = yield @normalize body[@recordSingleName()]
          else
            throw new Error "
              Record payload has not existed in response body.
            "
          yield return voRecord

      @public @async remove: FuncG([UnionG String, Number], NilT),
        default: (id)->
          requestObj = @requestFor(
            requestType: 'remove'
            recordName: @delegate.name
            id: id
          )
          res = yield @makeRequest requestObj

          if res.status >= 400
            throw new Error "
              Request failed with status #{res.status} #{res.message}
            "
          yield return

      @public @async take: FuncG([UnionG String, Number], MaybeG RecordInterface),
        default: (id)->
          requestObj = @requestFor(
            requestType: 'take'
            recordName: @delegate.name
            id: id
          )
          res = yield @makeRequest requestObj

          if res.status >= 400
            throw new Error "
              Request failed with status #{res.status} #{res.message}
            "

          { body } = res
          if body? and body isnt ''
            body = JSON.parse body if _.isString body
            voRecord = yield @normalize body[@recordSingleName()]
          else
            throw new Error "
              Record payload has not existed in response body.
            "
          yield return voRecord

      @public @async takeMany: FuncG([ListG UnionG String, Number], CursorInterface),
        default: (ids)->
          records = yield ids.map (id)=>
            @take id
          yield return Cursor.new null, records

      @public @async takeAll: FuncG([], CursorInterface),
        default: ->
          requestObj = @requestFor(
            requestType: 'takeAll'
            recordName: @delegate.name
          )
          res = yield @makeRequest requestObj

          if res.status >= 400
            throw new Error "
              Request failed with status #{res.status} #{res.message}
            "

          { body } = res
          if body? and body isnt ''
            body = JSON.parse body if _.isString body
            vhRecordsData = body[@recordMultipleName()]
            voCursor = Cursor.new @, vhRecordsData
          else
            throw new Error "
              Record payload has not existed in response body.
            "
          yield return voCursor

      @public @async override: FuncG([UnionG(String, Number), RecordInterface], RecordInterface),
        default: (id, aoRecord)->
          requestObj = @requestFor(
            requestType: 'override'
            recordName: @delegate.name
            snapshot: yield @serialize aoRecord
            id: id
          )
          res = yield @makeRequest requestObj

          if res.status >= 400
            throw new Error "
              Request failed with status #{res.status} #{res.message}
            "

          { body } = res
          if body? and body isnt ''
            body = JSON.parse body if _.isString body
            voRecord = yield @normalize body[@recordSingleName()]
          else
            throw new Error "
              Record payload has not existed in response body.
            "
          yield return voRecord

      @public @async includes: FuncG([UnionG String, Number], Boolean),
        default: (id)->
          record = yield @take id
          yield return record?

      @public @async length: FuncG([], Number),
        default: ->
          cursor = yield @takeAll()
          return yield cursor.count()

      @public headers: MaybeG DictG String, String
      @public host: String,
        default: 'http://localhost'
      @public namespace: String,
        default: ''
      @public queryEndpoint: String,
        default: 'query'

      @public headersForRequest: FuncG(MaybeG(InterfaceG {
        requestType: String
        recordName: String
        snapshot: MaybeG Object
        id: MaybeG String
        query: MaybeG Object
        isCustomReturn: MaybeG Boolean
      }), DictG String, String),
        default: (params)->
          headers = @headers ? {}
          headers['Accept'] = 'application/json'
          headers

      @public methodForRequest: FuncG(InterfaceG({
        requestType: String
        recordName: String
        snapshot: MaybeG Object
        id: MaybeG String
        query: MaybeG Object
        isCustomReturn: MaybeG Boolean
      }), String),
        default: ({requestType})->
          switch requestType
            when 'takeAll' then 'GET'
            when 'take' then 'GET'
            when 'push' then 'POST'
            when 'override' then 'PUT'
            when 'remove' then 'DELETE'
            else
              'GET'

      @public dataForRequest: FuncG(InterfaceG({
        requestType: String
        recordName: String
        snapshot: MaybeG Object
        id: MaybeG String
        query: MaybeG Object
        isCustomReturn: MaybeG Boolean
      }), MaybeG Object),
        default: ({recordName, snapshot, requestType, query})->
          if snapshot? and requestType in ['push', 'override']
            return snapshot
          else
            return

      @public urlForRequest: FuncG(InterfaceG({
        requestType: String
        recordName: String
        snapshot: MaybeG Object
        id: MaybeG String
        query: MaybeG Object
        isCustomReturn: MaybeG Boolean
      }), String),
        default: (params)->
          {recordName, snapshot, id, requestType, query} = params
          @buildURL recordName, snapshot, id, requestType, query

      @public pathForType: FuncG(String, String),
        default: (recordName)->
          inflect.pluralize inflect.underscore recordName.replace /Record$/, ''

      @public urlPrefix: FuncG([MaybeG(String), MaybeG String], String),
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

      @public makeURL: FuncG([String, MaybeG(Object), MaybeG(UnionG Number, String), MaybeG Boolean], String),
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

      @public urlForTakeAll: FuncG([String, MaybeG Object], String),
        default: (recordName, query)->
          @makeURL recordName, query, null, no

      @public urlForTake: FuncG([String, String], String),
        default: (recordName, id)->
          @makeURL recordName, null, id, no

      @public urlForPush: FuncG([String, Object], String),
        default: (recordName, snapshot)->
          @makeURL recordName, null, null, no

      @public urlForRemove: FuncG([String, String], String),
        default: (recordName, id)->
          @makeURL recordName, null, id, no

      @public urlForOverride: FuncG([String, Object, String], String),
        default: (recordName, snapshot, id)->
          @makeURL recordName, null, id, no

      @public buildURL: FuncG([String, MaybeG(Object), MaybeG(String), String, MaybeG Object], String),
        default: (recordName, snapshot, id, requestType, query)->
          switch requestType
            when 'takeAll'
              @urlForTakeAll recordName, query
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

      @public requestFor: FuncG(InterfaceG({
        requestType: String
        recordName: String
        snapshot: MaybeG Object
        id: MaybeG String
        query: MaybeG Object
        isCustomReturn: MaybeG Boolean
      }), StructG {
        method: String
        url: String
        headers: DictG String, String
        data: MaybeG Object
      }),
        default: (params)->
          method  = @methodForRequest params
          url     = @urlForRequest params
          headers = @headersForRequest params
          data    = @dataForRequest params
          return {method, url, headers, data}

      # может быть переопределно другим миксином, который будет посылать запросы через jQuery.ajax например
      @public @async sendRequest: FuncG(StructG({
        method: String
        url: String
        options: InterfaceG {
          json: EnumG [yes]
          headers: DictG String, String
          body: MaybeG Object
        }
      }), StructG {
        body: MaybeG AnyT
        headers: DictG String, String
        status: Number
        message: MaybeG String
      }),
        default: ({method, url, options})->
          return yield request method, url, options

      # может быть переопределно другим миксином, который будет посылать запросы через jQuery.ajax например
      @public requestToHash: FuncG(StructG({
        method: String
        url: String
        headers: DictG String, String
        data: MaybeG Object
      }), StructG {
        method: String
        url: String
        options: InterfaceG {
          json: EnumG [yes]
          headers: DictG String, String
          body: MaybeG Object
        }
      }),
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

      @public @async makeRequest: FuncG(StructG({
        method: String
        url: String
        headers: DictG String, String
        data: MaybeG Object
      }), StructG {
        body: MaybeG AnyT
        headers: DictG String, String
        status: Number
        message: MaybeG String
      }),
        default: (requestObj)-> # result of requestFor
          {
            LogMessage: {
              SEND_TO_LOG
              LEVELS
              DEBUG
            }
          } = Module::
          hash = @requestToHash requestObj
          @sendNotification(SEND_TO_LOG, "ThinHttpCollectionMixin::makeRequest hash #{JSON.stringify hash}", LEVELS[DEBUG])
          return yield @sendRequest hash


      @initializeMixin()
