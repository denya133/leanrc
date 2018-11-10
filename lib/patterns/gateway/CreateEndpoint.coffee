

module.exports = (Module)->
  {
    EndpointInterface
    CrudEndpointMixin
    Endpoint
    Utils: { statuses }
  } = Module::

  HTTP_CONFLICT     = statuses 'conflict'
  UNAUTHORIZED      = statuses 'unauthorized'
  UPGRADE_REQUIRED  = statuses 'upgrade required'

  class CreateEndpoint extends Endpoint
    @inheritProtected()
    @implements EndpointInterface
    @include CrudEndpointMixin
    @module Module

    @public init: Function,
      default: (args...) ->
        @super args...
        @pathParam 'v', @versionSchema
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
        return


    @initialize()
