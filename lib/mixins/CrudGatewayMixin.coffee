

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
  {
    Gateway
    Utils: { _, inflect, joi, statuses }
  } = Module::

  HTTP_NOT_FOUND    = statuses 'not found'
  HTTP_CONFLICT     = statuses 'conflict'
  UNAUTHORIZED      = statuses 'unauthorized'
  FORBIDDEN         = statuses 'forbidden'
  UPGRADE_REQUIRED  = statuses 'upgrade required'

  Module.defineMixin Gateway, (BaseClass) ->
    class CrudGatewayMixin extends BaseClass
      @inheritProtected()
      # @implements Module::CrudGatewayMixinInterface

      @public keyName: String,
        get: ->
          {keyName, entityName} = @getData()
          inflect.singularize inflect.underscore keyName ? entityName

      @public itemEntityName: String,
        get: ->
          {entityName} = @getData()
          inflect.singularize inflect.underscore entityName

      @public listEntityName: String,
        get: ->
          {entityName} = @getData()
          inflect.pluralize inflect.underscore entityName

      @public schema: Object,
        get: ->
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
          The version of api endpoint in semver format `^x.x`
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

          return


    CrudGatewayMixin.initializeMixin()
