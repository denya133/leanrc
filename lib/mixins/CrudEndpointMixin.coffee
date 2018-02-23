

###
```coffee

module.exports = (Module)->
  {
    Endpoint
    CrudEndpointMixin
  }
  UploadsDownloadEndpoint extends Endpoint
    @inheritProtected()
    @include CrudEndpointMixin
    @module Module

    @public init: Function,
      default: (args...)->
        @super args...
        @pathParam    'v', @versionSchema
        .pathParam    'space', joi.string().required()
        .pathParam    @keyName, @keySchema
        .pathParam    'attachment', joi.string().required()
        .response     joi.binary(), 'The binary stream of upload file'
        .error        UNAUTHORIZED
        .summary      'Download attached file'
        .description  '
          Find and send as stream attached file.
        '


  UploadsDownloadEndpoint.initialize()
```
###


module.exports = (Module)->
  {
    APPLICATION_MEDIATOR

    Endpoint
    Utils: {
      _, joi, inflect
    }
  } = Module::

  Module.defineMixin 'CrudEndpointMixin', (BaseClass = Endpoint) ->
    class extends BaseClass
      @inheritProtected()

      ipsKeyName = @private keyName: String
      ipsEntityName = @private entityName: String
      ipsRecordName = @private recordName: String
      ipoSchema = @private schema: Object
      Endpoint.keyNames ?= {}
      Endpoint.itemEntityNames ?= {}
      Endpoint.listEntityNames ?= {}
      Endpoint.itemSchemas ?= {}
      Endpoint.listSchemas ?= {}

      @public keyName: String,
        get: ->
          keyName = @[ipsKeyName] ? @[ipsEntityName]
          Endpoint.keyNames[keyName] ?= inflect.singularize inflect.underscore keyName

      @public itemEntityName: String,
        get: -> Endpoint.itemEntityNames[@[ipsEntityName]] ?= inflect.singularize inflect.underscore @[ipsEntityName]

      @public listEntityName: String,
        get: -> Endpoint.listEntityNames[@[ipsEntityName]] ?= inflect.pluralize inflect.underscore @[ipsEntityName]

      @public schema: Object,
        get: -> @[ipoSchema]

      @public listSchema: Object,
        get: ->
          Endpoint.listSchemas["#{@[ipsEntityName]}|#{@[ipsRecordName]}"] ?= joi.object "#{@listEntityName}": joi.array().items @schema

      @public itemSchema: Object,
        get: ->
          Endpoint.itemSchemas["#{@[ipsEntityName]}|#{@[ipsRecordName]}"] ?= joi.object "#{@itemEntityName}": @schema

      @public keySchema: Object,
        default: joi.string().required().description 'The key of the objects.'

      @public querySchema: Object,
        default: joi.string().empty('{}').optional().default '{}', '
          The query for finding objects.
        '

      @public executeQuerySchema: Object,
        default: joi.object(query: joi.object().required()).required(), '
          The query for execute.
        '

      @public bulkResponseSchema: Object,
        default: joi.object success: joi.boolean()

      @public versionSchema: Object,
        default: joi.string().required().description '
          The version of api endpoint in semver format `^x.x`
        '

      @public ApplicationModule: Module::Class,
        get: -> @gateway?.ApplicationModule ? @Module

      @public init: Function,
        default: (args...) ->
          @super args...
          [ options ] = args
          { keyName, entityName, recordName } = options
          @[ipsKeyName] = keyName
          @[ipsEntityName] = entityName
          @[ipsRecordName] = recordName
          if recordName? and _.isString recordName
            recordName = inflect.camelize recordName
            recordName += 'Record'  unless /Record$/.test recordName
            voSchema = @gateway?.getSchema recordName
            voSchema ?= @ApplicationModule::[recordName].schema
            @[ipoSchema] = voSchema
          @[ipoSchema] ?= {}


      @initializeMixin()
