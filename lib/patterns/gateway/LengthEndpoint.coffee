

module.exports = (Module)->
  {
    FuncG, InterfaceG
    GatewayInterface
    EndpointInterface
    CrudEndpointMixin
    Endpoint
    Utils: { statuses, joi }
  } = Module::

  UNAUTHORIZED      = statuses 'unauthorized'
  UPGRADE_REQUIRED  = statuses 'upgrade required'

  class LengthEndpoint extends Endpoint
    @inheritProtected()
    @implements EndpointInterface
    @include CrudEndpointMixin
    @module Module

    @public init: FuncG(InterfaceG(gateway: GatewayInterface)),
      default: (args...) ->
        @super args...
        @pathParam 'v', @versionSchema
        @response joi.number(), "
          The length of #{@listEntityName} collection.
        "
        @error UNAUTHORIZED
        @error UPGRADE_REQUIRED
        @summary "
          Length of #{@listEntityName} collection
        "
        @description  "
          Retrieves a length of
          #{@listEntityName} collection.
        "
        return


    @initialize()
