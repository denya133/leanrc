

module.exports = (Module)->
  {
    CrudEndpointMixin
    Utils: { statuses }
  } = Module::

  HTTP_NOT_FOUND    = statuses 'not found'
  UNAUTHORIZED      = statuses 'unauthorized'
  UPGRADE_REQUIRED  = statuses 'upgrade required'

  class ModelingDetailEndpoint extends Module::Endpoint
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
        @response @itemSchema, "
          The #{@itemEntityName}.
        "
        @error HTTP_NOT_FOUND
        @error UNAUTHORIZED
        @error UPGRADE_REQUIRED
        @summary "
          Fetch the #{@itemEntityName}
        "
        @description "
          Retrieves the
          #{@itemEntityName} by its key.
        "

    @initialize()
