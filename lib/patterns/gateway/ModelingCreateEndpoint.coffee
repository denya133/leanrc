

module.exports = (Module)->
  {
    CrudEndpointMixin
    Utils: { statuses }
  } = Module::

  HTTP_CONFLICT     = statuses 'conflict'
  UNAUTHORIZED      = statuses 'unauthorized'
  UPGRADE_REQUIRED  = statuses 'upgrade required'

  class ModelingCreateEndpoint extends Module::Endpoint
    @inheritProtected()
    # @implements Module::EndpointInterface
    @include CrudEndpointMixin
    @module Module

    @public init: Function,
      default: (args...) ->
        @super args...
        @pathParam 'v', @versionSchema
        @header 'Authorization', joi.string().required(), "
          Authorization header for internal services.
        "
        @body @itemSchema.required(), "
          The #{@itemEntityName} to create.
        "
        @response 201, @itemSchema, "
          The created #{@itemEntityName}.
        "
        @error HTTP_CONFLICT, "
          The #{@itemEntityName} already
          exists.
        "
        @error UNAUTHORIZED
        @error UPGRADE_REQUIRED
        @summary "
          Create a new #{@itemEntityName}
        "
        @description "
          Creates a new #{@itemEntityName}
          from the request body and
          returns the saved document.
        "

    @initialize()
