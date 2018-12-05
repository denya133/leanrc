

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
    PointerT
    FuncG, ListG, SubsetG, MaybeG
    EndpointInterface
    Gateway, Mixin
    Utils: { _, inflect, joi, statuses }
  } = Module::

  HTTP_NOT_FOUND    = statuses 'not found'
  HTTP_CONFLICT     = statuses 'conflict'
  UNAUTHORIZED      = statuses 'unauthorized'
  FORBIDDEN         = statuses 'forbidden'
  UPGRADE_REQUIRED  = statuses 'upgrade required'

  Module.defineMixin Mixin 'NamespacedGatewayMixin', (BaseClass = Gateway) ->
    class extends BaseClass
      @inheritProtected()

      ipoJoinedNamespacesMask = PointerT @private joinedNamespacesMask: MaybeG RegExp

      @public namespaces: FuncG([], ListG String),
        default: -> [
          'admining'
          'globaling'
          'guesting'
          'modeling'
          'personing'
          'sharing'
        ]

      @public joinedNamespacesMask: RegExp,
        get: -> @[ipoJoinedNamespacesMask] ? new RegExp "^(#{@namespaces().join '|'})_"

      @public getTrimmedEndpointName: FuncG([String, String], String),
        default: (asResourse, asAction) ->
          vsPath = "#{inflect.underscore asResourse}_#{asAction}_endpoint"
            .replace /\//g, '_'
            .replace /\_+/g, '_'
            .replace @joinedNamespacesMask, ''
          inflect.camelize vsPath

      @public getEndpoint: FuncG([String, String], SubsetG EndpointInterface),
        default: (asResourse, asAction) ->
          @getEndpointByName(@getEndpointName asResourse, asAction) ?
            @getEndpointByName(@getTrimmedEndpointName asResourse, asAction) ?
            @getStandardActionEndpoint asResourse, asAction

      @initializeMixin()
