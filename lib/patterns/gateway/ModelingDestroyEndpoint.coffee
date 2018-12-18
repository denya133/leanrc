

module.exports = (Module)->
  {
    FuncG, InterfaceG
    GatewayInterface
    EndpointInterface
    CrudEndpointMixin
    Endpoint
    Utils: { statuses, joi }
  } = Module::

  HTTP_NOT_FOUND    = statuses 'not found'
  UNAUTHORIZED      = statuses 'unauthorized'
  UPGRADE_REQUIRED  = statuses 'upgrade required'

  class ModelingDestroyEndpoint extends Endpoint
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
        @error HTTP_NOT_FOUND
        @error UNAUTHORIZED
        @error UPGRADE_REQUIRED
        @response null
        @summary "
          Remove the #{@itemEntityName}
        "
        @description "
          Deletes the #{@itemEntityName}
          from the database.
        "
        return


    @initialize()
