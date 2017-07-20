

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
  Module.defineMixin Module::Endpoint, (BaseClass) ->
    class CrudEndpointMixin extends BaseClass
      @inheritProtected()

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


    CrudEndpointMixin.initializeMixin()
