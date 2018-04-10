

module.exports = (Module)->
  {
    CrudEndpointMixin
    Utils: { statuses, joi }
  } = Module::

  UNAUTHORIZED      = statuses 'unauthorized'
  UPGRADE_REQUIRED  = statuses 'upgrade required'

  class LengthEndpoint extends Module::Endpoint
    @inheritProtected()
    # @implements Module::EndpointInterface
    @include CrudEndpointMixin
    @module Module

    @public init: Function,
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

    @initialize()
