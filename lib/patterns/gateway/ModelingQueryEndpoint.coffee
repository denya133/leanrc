

module.exports = (Module)->
  {
    NilT
    FuncG, InterfaceG
    GatewayInterface
    EndpointInterface
    CrudEndpointMixin
    Endpoint
    Utils: { statuses, joi }
  } = Module::

  UNAUTHORIZED      = statuses 'unauthorized'
  UPGRADE_REQUIRED  = statuses 'upgrade required'

  class ModelingQueryEndpoint extends Endpoint
    @inheritProtected()
    @implements EndpointInterface
    @include CrudEndpointMixin
    @module Module

    @public init: FuncG(InterfaceG(gateway: GatewayInterface), NilT),
      default: (args...) ->
        @super args...
        @pathParam 'v', @versionSchema
        @header 'Authorization', joi.string().required(), "
          Authorization header is required.
        "
        @body @executeQuerySchema, "
          The query for execute.
        "
        @response joi.array().items(joi.any()), "
          Any result.
        "
        @error UNAUTHORIZED
        @error UPGRADE_REQUIRED
        @summary "
          Execute some query
        "
        @description "
          This endpoint will been used from HttpCollectionMixin
        "
        return


    @initialize()
