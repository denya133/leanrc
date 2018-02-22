

###
```coffee
Module = require 'Module'

module.exports = (App)->
  App::CrudGateway extends Module::Gateway
    @inheritProtected()
    @include Module::NamespacedGatewayMixin

    @module App

  return App::CrudGateway.initialize()
```

###

module.exports = (Module)->
  {
    Gateway
    Utils: { _, inflect, joi, statuses }
  } = Module::

  HTTP_NOT_FOUND    = statuses 'not found'
  HTTP_CONFLICT     = statuses 'conflict'
  UNAUTHORIZED      = statuses 'unauthorized'
  FORBIDDEN         = statuses 'forbidden'
  UPGRADE_REQUIRED  = statuses 'upgrade required'

  Module.defineMixin 'NamespacedGatewayMixin', (BaseClass = Gateway) ->
    class extends BaseClass
      @inheritProtected()

      @public namespaces: Array,
        default: -> [
          'admining'
          'globaling'
          'guesting'
          'modeling'
          'personing'
          'sharing'
        ]

      @public getTrimmedEndpointName: Function,
        default: (asResourse, asAction) ->
          vsNamespaces = "(#{@namespaces().join '|'})"
          re = new RegExp "^#{vsNamespaces}_"
          vsPath = "#{inflect.underscore asResourse}_#{asAction}_endpoint"
            .replace /\//g, '_'
            .replace /\_+/g, '_'
            .replace re, ''
          inflect.camelize vsPath

      @public getEndpoint: Function,
        default: (asResourse, asAction) ->
          @ApplicationModule::[vsName = @getEndpointName asResourse, asAction] ?
            @tryLoadEndpoint(vsName) ?
            @ApplicationModule::[vsTrimmedName = @getTrimmedEndpointName asResourse, asAction] ?
            @tryLoadEndpoint(vsTrimmedName) ?
            @getStandardActionEndpoint asResourse, asAction

      @initializeMixin()
