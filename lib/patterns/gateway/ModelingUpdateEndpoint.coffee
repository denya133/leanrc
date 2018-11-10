

module.exports = (Module)->
  {
    EndpointInterface
    CrudEndpointMixin
    Endpoint
    Utils: { statuses, joi }
  } = Module::

  HTTP_NOT_FOUND    = statuses 'not found'
  HTTP_CONFLICT     = statuses 'conflict'
  UNAUTHORIZED      = statuses 'unauthorized'
  UPGRADE_REQUIRED  = statuses 'upgrade required'

  class ModelingUpdateEndpoint extends Endpoint
    @inheritProtected()
    @implements EndpointInterface
    @include CrudEndpointMixin
    @module Module

    @public init: Function,
      default: (args...) ->
        @super args...
        @pathParam 'v', @versionSchema
        @header 'Authorization', joi.string().required(), "
          Authorization header for internal services.
        "
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
        return


    @initialize()
