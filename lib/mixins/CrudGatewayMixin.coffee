_             = require 'lodash'
joi           = require 'joi'
inflect       = do require 'i'
statuses      = require 'statuses'


HTTP_NOT_FOUND    = statuses 'not found'
HTTP_CONFLICT     = statuses 'conflict'
UNAUTHORIZED      = statuses 'unauthorized'
FORBIDDEN         = statuses 'forbidden'
UPGRADE_REQUIRED  = statuses 'upgrade required'


###
```coffee
Module = require 'Module'

module.exports = (App)->
  App::CrudGateway extends Module::Gateway
    @inheritProtected()
    @include Module::CrudGatewayMixin

    @module App

  return App::CrudGateway.initialize()
```

###

module.exports = (Module)->
  Module.defineMixin Module::Gateway, (BaseClass) ->
    class CrudGatewayMixin extends BaseClass
      @inheritProtected()
      # @implements Module::CrudGatewayMixinInterface

      @public keyName: String,
        get: ->
          inflect.singularize inflect.underscore @getData().entityName

      @public itemEntityName: String,
        get: ->
          inflect.singularize inflect.underscore @getData().entityName

      @public listEntityName: String,
        get: ->
          inflect.pluralize inflect.underscore @getData().entityName

      @public schema: Object,
        get: ->
          # joi.object @getData().schema
          @getData().schema

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
          The version of api endpoint in format `vx.x`
        '

      @public onRegister: Function,
        default: (args...)->
          @super args...
          @swaggerDefinition 'list', (endpoint)->
            endpoint
              .pathParam 'v', @versionSchema
              .header 'Authorization', joi.string().optional(), "
                Authorization header for internal services.
              "
              .header 'NonLimitation', joi.string().optional(), "
                NonLimitation header for internal services.
              "
              .queryParam 'query', @querySchema, "
                The query for finding
                #{@listEntityName}.
              "
              .response @listSchema, "
                The #{@listEntityName}.
              "
              .error UNAUTHORIZED
              .error UPGRADE_REQUIRED
              .summary "
                List of filtered #{@listEntityName}
              "
              .description  "
                Retrieves a list of filtered
                #{@listEntityName} by using query.
              "

          @swaggerDefinition 'detail', (endpoint)->
            endpoint
              .pathParam 'v', @versionSchema
              .header 'Authorization', joi.string().optional(), "
                Authorization header for internal services.
              "
              .pathParam @keyName, @keySchema
              .response @itemSchema, "
                The #{@itemEntityName}.
              "
              .error HTTP_NOT_FOUND
              .error UNAUTHORIZED
              .error UPGRADE_REQUIRED
              .summary "
                Fetch the #{@itemEntityName}
              "
              .description "
                Retrieves the
                #{@itemEntityName} by its key.
              "

          @swaggerDefinition 'create', (endpoint)->
            endpoint
              .pathParam 'v', @versionSchema
              .header 'Authorization', joi.string().optional(), "
                Authorization header for internal services.
              "
              .body @itemSchema.required(), "
                The #{@itemEntityName} to create.
              "
              .response 201, @itemSchema, "
                The created #{@itemEntityName}.
              "
              .error HTTP_CONFLICT, "
                The #{@itemEntityName} already
                exists.
              "
              .error UNAUTHORIZED
              .error UPGRADE_REQUIRED
              .summary "
                Create a new #{@itemEntityName}
              "
              .description "
                Creates a new #{@itemEntityName}
                from the request body and
                returns the saved document.
              "

          @swaggerDefinition 'update', (endpoint)->
            endpoint
              .pathParam 'v', @versionSchema
              .header 'Authorization', joi.string().optional(), "
                Authorization header for internal services.
              "
              .pathParam @keyName, @keySchema
              .body @itemSchema.required(), "
                The data to replace the
                #{@itemEntityName} with.
              "
              .response @itemSchema, "
                The replaced #{@itemEntityName}.
              "
              .error HTTP_NOT_FOUND
              .error HTTP_CONFLICT
              .error UNAUTHORIZED
              .error UPGRADE_REQUIRED
              .summary "
                Replace the #{@itemEntityName}
              "
              .description "
                Replaces an existing
                #{@itemEntityName} with the
                request body and returns the new document.
              "

          @swaggerDefinition 'delete', (endpoint)->
            endpoint
              .pathParam 'v', @versionSchema
              .header 'Authorization', joi.string().optional(), "
                Authorization header for internal services.
              "
              .pathParam @keyName, @keySchema
              .error HTTP_NOT_FOUND
              .error UNAUTHORIZED
              .error UPGRADE_REQUIRED
              .response null
              .summary "
                Remove the #{@itemEntityName}
              "
              .description "
                Deletes the #{@itemEntityName}
                from the database.
              "

          @swaggerDefinition 'query', (endpoint)->
            endpoint
              .pathParam 'v', @versionSchema
              .header 'Authorization', joi.string().required(), "
                Authorization header is required.
              "
              .body @executeQuerySchema, "
                The query for execute.
              "
              .response joi.array().items(joi.any()), "
                Any result.
              "
              .error UNAUTHORIZED
              .error UPGRADE_REQUIRED
              .summary "
                Execute some query
              "
              .description "
                This endpoint will been used from HttpCollectionMixin
              "

          return


    CrudGatewayMixin.initializeMixin()
