

module.exports = (Module)->
  {
    NilT
    FuncG, InterfaceG
    GatewayInterface
    EndpointInterface
    CrudEndpointMixin
    Endpoint
    Utils: { statuses }
  } = Module::

  HTTP_NOT_FOUND    = statuses 'not found'
  UNAUTHORIZED      = statuses 'unauthorized'
  UPGRADE_REQUIRED  = statuses 'upgrade required'

  class DestroyEndpoint extends Endpoint
    @inheritProtected()
    @implements EndpointInterface
    @include CrudEndpointMixin
    @module Module

    @public init: FuncG(InterfaceG(gateway: GatewayInterface), NilT),
      default: (args...) ->
        @super args...
        @pathParam 'v', @versionSchema
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
