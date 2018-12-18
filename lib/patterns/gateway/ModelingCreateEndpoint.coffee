

module.exports = (Module)->
  {
    FuncG, InterfaceG
    GatewayInterface
    EndpointInterface
    CrudEndpointMixin
    Endpoint
    Utils: { statuses, joi }
  } = Module::

  HTTP_CONFLICT     = statuses 'conflict'
  UNAUTHORIZED      = statuses 'unauthorized'
  UPGRADE_REQUIRED  = statuses 'upgrade required'

  class ModelingCreateEndpoint extends Endpoint
    @inheritProtected()
    @implements EndpointInterface
    @include CrudEndpointMixin
    @module Module

    @public init: FuncG(InterfaceG(gateway: GatewayInterface)),
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
        return


    @initialize()
