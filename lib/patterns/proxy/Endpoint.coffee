_             = require 'lodash'
joi           = require 'joi'
inflect       = require('i')()
status        = require 'statuses'
RC            = require 'RC'

HTTP_NOT_FOUND    = status 'not found'
HTTP_CONFLICT     = status 'conflict'
UNAUTHORIZED      = status 'unauthorized'
FORBIDDEN         = status 'forbidden'
UPGRADE_REQUIRED  = status 'upgrade required'


module.exports = (LeanRC)->
  class LeanRC::Endpoint extends LeanRC::Proxy
    @inheritProtected()
    @implements LeanRC::EndpointInterface

    @Module: LeanRC

    @public @static swaggerDefinition: Function,
      args: [String, Function]
      return: RC::Constants.NILL
      default: (asAction, lambda)->
        vsAction = inflect.camelize asAction
        @public "swaggerDefinitionFor#{vsAction}": Function,
          args: [LeanRC::Endpoint] # над этим надо подумать
          return: LeanRC::Endpoint # над этим надо подумать
          default: lambda
        return

    @public @static keyName: Function,
      default: ->
        inflect.singularize inflect.underscore @name.replace 'Endpoint', ''

    @public @static schema: Function,
      default: ->
        joi.object @::Model.serializableAttributes()

    @public @static listSchema: Function,
      default: ->
        joi.object "#{inflect.pluralize inflect.underscore @::Model.name}": joi.array().items @schema()

    @public @static itemSchema: Function,
      default: ->
        joi.object "#{inflect.underscore @::Model.name}": @schema()

    @swaggerDefinition 'list', (endpoint)->
      endpoint
        .pathParam   'v', joi.string().required(), "
          The version of api endpoint in format `vx.x`
        "
        .queryParam   'query', @querySchema, "
          The query for finding
          #{inflect.pluralize inflect.underscore @::Model.name}.
        "
        .response     @listSchema(), "
          The #{inflect.pluralize inflect.underscore @::Model.name}.
        "
        .error        UNAUTHORIZED
        .error        UPGRADE_REQUIRED
        .summary      "
          List of filtered #{inflect.pluralize inflect.underscore @::Model.name}
        "
        .description  "
          Retrieves a list of filtered
          #{inflect.pluralize inflect.underscore @::Model.name} by using query.
        "

    @swaggerDefinition 'detail', (endpoint)->
      endpoint
        .pathParam   'v', joi.string().required(), "
          The version of api endpoint in format `vx.x`
        "
        .pathParam    @keyName(), @keySchema
        .response     @itemSchema(), "
          The #{inflect.singularize inflect.underscore @::Model.name}.
        "
        .error        HTTP_NOT_FOUND
        .error        UNAUTHORIZED
        .error        UPGRADE_REQUIRED
        .summary      "
          Fetch the #{inflect.singularize inflect.underscore @::Model.name}
        "
        .description  "
          Retrieves the
          #{inflect.singularize inflect.underscore @::Model.name} by its key.
        "

    @swaggerDefinition 'create', (endpoint)->
      endpoint
        .pathParam   'v', joi.string().required(), "
          The version of api endpoint in format `vx.x`
        "
        .body @itemSchema().required(), "
          The #{inflect.singularize inflect.underscore @::Model.name} to create.
        "
        .response     201, @itemSchema(), "
          The created #{inflect.singularize inflect.underscore @::Model.name}.
        "
        .error        HTTP_CONFLICT, "
          The #{inflect.singularize inflect.underscore @::Model.name} already
          exists.
        "
        .error        UNAUTHORIZED
        .error        UPGRADE_REQUIRED
        .summary      "
          Create a new #{inflect.singularize inflect.underscore @::Model.name}
        "
        .description  "
          Creates a new #{inflect.singularize inflect.underscore @::Model.name}
          from the request body and
          returns the saved document.
        "

    @swaggerDefinition 'update', (endpoint)->
      endpoint
        .pathParam   'v', joi.string().required(), "
          The version of api endpoint in format `vx.x`
        "
        .pathParam @keyName(), @keySchema
        .body         @itemSchema().required(), "
          The data to replace the
          #{inflect.singularize inflect.underscore @::Model.name} with.
        "
        .response     @itemSchema(), "
          The new #{inflect.singularize inflect.underscore @::Model.name}.
        "
        .error        HTTP_NOT_FOUND
        .error        HTTP_CONFLICT
        .error        UNAUTHORIZED
        .error        UPGRADE_REQUIRED
        .summary      "
          Replace the #{inflect.singularize inflect.underscore @::Model.name}
        "
        .description  "
          Replaces an existing
          #{inflect.singularize inflect.underscore @::Model.name} with the
          request body and returns the new document.
        "

    @swaggerDefinition 'patch', (endpoint)->
      endpoint
        .pathParam   'v', joi.string().required(), "
          The version of api endpoint in format `vx.x`
        "
        .pathParam @keyName(), @keySchema
        .body         @itemSchema().description("
          The data to update the
          #{inflect.singularize inflect.underscore @::Model.name} with.
        ").required()
        .response     @itemSchema(), "
          The updated #{inflect.singularize inflect.underscore @::Model.name}.
        "
        .error        HTTP_NOT_FOUND
        .error        HTTP_CONFLICT
        .error        UNAUTHORIZED
        .error        UPGRADE_REQUIRED
        .summary      "
          Update the #{inflect.singularize inflect.underscore @::Model.name}
        "
        .description  "
          Patches the #{inflect.singularize inflect.underscore @::Model.name}
          with the request body and returns the updated document.
        "

    @swaggerDefinition 'delete', (endpoint)->
      endpoint
        .pathParam   'v', joi.string().required(), "
          The version of api endpoint in format `vx.x`
        "
        .pathParam @keyName(), @keySchema
        .error        HTTP_NOT_FOUND
        .error        UNAUTHORIZED
        .error        UPGRADE_REQUIRED
        .response     null
        .summary      "
          Remove the #{inflect.singularize inflect.underscore @::Model.name}
        "
        .description  "
          Deletes the #{inflect.singularize inflect.underscore @::Model.name}
          from the database.
        "

    @public @static keySchema: Object,
      default: joi.string().required().description 'The key of the objects.'
    @public @static querySchema: Object,
      default: joi.string().empty('{}').optional().default '{}', '
      The query for finding objects.
    '

    @public @static prepareItem: Function,
      default: (item)->
        key = opts.singularize ? inflect.singularize inflect.underscore @::Model.name
        data = @serializeForClient item
        return "#{key}": data

    @public @static prepareList: Function,
      default: (items, meta)->
        key = opts.pluralize ? inflect.pluralize inflect.underscore @::Model.name
        results = []
        items.forEach (item) =>
          results.push @serializeForClient item
        return "#{key}": results, meta: meta

    @public @static serializeForClient: Function,
      default: (item)-> item


  return LeanRC::Endpoint.initialize()
