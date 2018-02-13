

module.exports = (Module)->
  {
    CrudEndpointMixin
    Utils: { statuses }
  } = Module::

  HTTP_NOT_FOUND    = statuses 'not found'
  HTTP_CONFLICT     = statuses 'conflict'
  UNAUTHORIZED      = statuses 'unauthorized'
  UPGRADE_REQUIRED  = statuses 'upgrade required'

  class UpdateEndpoint extends Module::Endpoint
    @inheritProtected()
    # @implements Module::EndpointInterface
    @include CrudEndpointMixin
    @module Module

    @public init: Function,
      default: (args...) ->
        @super args...
        @pathParam 'v', @versionSchema
        @body @itemSchema.required(), "
          The data to replace the
          #{@itemEntityName} with.
        "
        @response @itemSchema, "
          The replaced #{@itemEntityName}.
        "
        @error HTTP_NOT_FOUND
        @error HTTP_CONFLICT
        @error UNAUTHORIZED
        @error UPGRADE_REQUIRED
        @summary "
          Replace the #{@itemEntityName}
        "
        @description "
          Replaces an existing
          #{@itemEntityName} with the
          request body and returns the new document.
        "

    @initialize()
