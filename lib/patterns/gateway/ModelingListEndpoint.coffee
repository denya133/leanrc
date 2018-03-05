

module.exports = (Module)->
  {
    CrudEndpointMixin
    Utils: { statuses, joi }
  } = Module::

  UNAUTHORIZED      = statuses 'unauthorized'
  UPGRADE_REQUIRED  = statuses 'upgrade required'

  class ModelingListEndpoint extends Module::Endpoint
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

    @initialize()
