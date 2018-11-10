

module.exports = (Module)->
  {
    EndpointInterface
    CrudEndpointMixin
    Endpoint
    Utils: { statuses, joi }
  } = Module::

  UNAUTHORIZED      = statuses 'unauthorized'
  UPGRADE_REQUIRED  = statuses 'upgrade required'

  class CountEndpoint extends Endpoint
    @inheritProtected()
    @implements EndpointInterface
    @include CrudEndpointMixin
    @module Module

    @public init: Function,
      default: (args...) ->
        @super args...
        @pathParam 'v', @versionSchema
        @queryParam 'query', @querySchema, "
          The query for counting
          #{@listEntityName}.
        "
        @response joi.number(), "
          The count of #{@listEntityName}.
        "
        @error UNAUTHORIZED
        @error UPGRADE_REQUIRED
        @summary "
          Count of filtered #{@listEntityName}
        "
        @description  "
          Retrieves a count of filtered
          #{@listEntityName} by using query.
        "
        return


    @initialize()
