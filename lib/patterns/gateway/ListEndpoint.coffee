

module.exports = (Module)->
  {
    EndpointInterface
    CrudEndpointMixin
    Endpoint
    Utils: { statuses }
  } = Module::

  UNAUTHORIZED      = statuses 'unauthorized'
  UPGRADE_REQUIRED  = statuses 'upgrade required'

  class ListEndpoint extends Endpoint
    @inheritProtected()
    @implements EndpointInterface
    @include CrudEndpointMixin
    @module Module

    @public init: Function,
      default: (args...) ->
        @super args...
        @pathParam 'v', @versionSchema
        @queryParam 'query', @querySchema, "
          The query for finding
          #{@listEntityName}.
        "
        @response @listSchema, "
          The #{@listEntityName}.
        "
        @error UNAUTHORIZED
        @error UPGRADE_REQUIRED
        @summary "
          List of filtered #{@listEntityName}
        "
        @description  "
          Retrieves a list of filtered
          #{@listEntityName} by using query.
        "
        return


    @initialize()
