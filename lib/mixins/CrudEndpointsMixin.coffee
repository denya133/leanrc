_             = require 'lodash'
joi           = require 'joi'
inflect       = require('i')()
status        = require 'statuses'


HTTP_NOT_FOUND    = status 'not found'
HTTP_CONFLICT     = status 'conflict'
UNAUTHORIZED      = status 'unauthorized'
FORBIDDEN         = status 'forbidden'
UPGRADE_REQUIRED  = status 'upgrade required'


###
```coffee
Module = require 'Module'

module.exports = (App)->
  App::CrudGateway extends Module::Gateway
    @inheritProtected()
    @include Module::CrudEndpointsMixin

    @module App

  return App::CrudGateway.initialize()
```

###

module.exports = (Module)->
  Module.defineMixin 'CrudEndpointsMixin', (BaseClass) ->
    class CrudEndpointsMixin extends BaseClass
      @inheritProtected()
      @implements Module::CrudEndpointsMixinInterface

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

          @swaggerDefinition 'patch', (endpoint)->
            endpoint
              .pathParam 'v', @versionSchema
              .pathParam @keyName, @keySchema
              .body @itemSchema.required(), "
                The data to update the
                #{@itemEntityName} with.
              "
              .response @itemSchema, "
                The updated #{@itemEntityName}.
              "
              .error HTTP_NOT_FOUND
              .error HTTP_CONFLICT
              .error UNAUTHORIZED
              .error UPGRADE_REQUIRED
              .summary "
                Update the #{@itemEntityName}
              "
              .description "
                Patches the #{@itemEntityName}
                with the request body and returns the updated document.
              "

          @swaggerDefinition 'delete', (endpoint)->
            endpoint
              .pathParam 'v', @versionSchema
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

          @swaggerDefinition 'bulkUpdate', (endpoint)->
            endpoint
              .pathParam 'v', @versionSchema
              .queryParam 'query', @querySchema, "
                The query for bulk updating
                #{@listEntityName}.
              "
              .body @itemSchema.required(), "
                The data to replace the
                #{@itemEntityName} with.
              "
              .response @bulkResponseSchema, "
                Bulk replace has been realized.
              "
              .error HTTP_NOT_FOUND
              .error HTTP_CONFLICT
              .error UNAUTHORIZED
              .error UPGRADE_REQUIRED
              .summary "
                Replace some #{@listEntityName}
              "
              .description "
                Replaces some existing
                #{@listEntityName} with the
                request body.
              "

          @swaggerDefinition 'bulkPatch', (endpoint)->
            endpoint
              .pathParam 'v', @versionSchema
              .queryParam 'query', @querySchema, "
                The query for bulk updating
                #{@listEntityName}.
              "
              .body @itemSchema.required(), "
                The data to update the
                #{@itemEntityName} with.
              "
              .response @bulkResponseSchema, "
                Bulk update has been realized.
              "
              .error HTTP_NOT_FOUND
              .error HTTP_CONFLICT
              .error UNAUTHORIZED
              .error UPGRADE_REQUIRED
              .summary "
                Update some #{@listEntityName}
              "
              .description "
                Patches some existing #{@listEntityName}
                with the request body.
              "

          @swaggerDefinition 'bulkDelete', (endpoint)->
            endpoint
              .pathParam 'v', @versionSchema
              .queryParam 'query', @querySchema, "
                The query for bulk updating
                #{@listEntityName}.
              "
              .error HTTP_NOT_FOUND
              .error UNAUTHORIZED
              .error UPGRADE_REQUIRED
              .response @bulkResponseSchema, "
                Bulk delete has been realized.
              "
              .summary "
                Remove some #{@listEntityName}
              "
              .description "
                Deletes some existing #{@listEntityName}
                from the database.
              "

          return


    CrudEndpointsMixin.initializeMixin()
