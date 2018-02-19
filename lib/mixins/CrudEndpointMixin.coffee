

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
    Endpoint,
    Utils: {
      _, joi, inflect
    }
  } = Module::

  Module.defineMixin 'CrudEndpointMixin', (BaseClass = Endpoint) ->
    class extends BaseClass
      @inheritProtected()

      ipsKeyName = @private keyName: String
      ipsEntityName = @private entityName: String
      ipoSchema = @private schema: Object

      ###
      @public keyName: String,
        get: -> @gateway.keyName

      @public itemEntityName: String,
        get: -> @gateway.itemEntityName

      @public listEntityName: String,
        get: -> @gateway.listEntityName

      @public schema: Object,
        get: -> @gateway.schema

      @public listSchema: Object,
        get: -> @gateway.listSchema

      @public itemSchema: Object,
        get: -> @gateway.itemSchema

      @public keySchema: Object,
        get: -> @gateway.keySchema

      @public querySchema: Object,
        get: -> @gateway.querySchema

      @public bulkResponseSchema: Object,
        get: -> @gateway.bulkResponseSchema

      @public versionSchema: Object,
        get: -> @gateway.versionSchema
      ###
      @public keyName: String,
        get: ->
          inflect.singularize inflect.underscore @[ipsKeyName] ? @[ipsEntityName]

      @public itemEntityName: String,
        get: -> inflect.singularize inflect.underscore @[ipsEntityName]

      @public listEntityName: String,
        get: -> inflect.pluralize inflect.underscore @[ipsEntityName]

      @public schema: Object,
        get: -> @[ipoSchema]

      @public listSchema: Object,
        get: ->
          joi.object "#{@listEntityName}": joi.array().items @schema

      @public itemSchema: Object,
        get: ->
          joi.object "#{@itemEntityName}": @schema

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

      @public init: Function,
        default: (args...) ->
          @super args...
          [ options ] = args
          { keyName, entityName, recordName } = options
          @[ipsKeyName] = keyName
          @[ipsEntityName] = entityName
          if recordName? and _.isString recordName
            recordName += 'Record'  unless /Record$/.test recordName
            Record = @Module::[inflect.camelize recordName]
            @[ipoSchema] = Record.schema
          @[ipoSchema] ?= {}


      @initializeMixin()
