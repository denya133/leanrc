

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
          vsResource = inflect.underscore @getEndpointName asResourse, asAction
          @namespaces().some (vsNamespace) ->
            re = new RegExp "^#{vsNamespace}_"
            if re.test vsResource
              vsResource = vsResource.replace re, ''
              return yes
            return no
          inflect.camelize vsResource

      @public getEndpoint: Function,
        default: (asResourse, asAction) ->
          vsEndpointName = @getEndpointName asResourse, asAction
          vsTrimmedEndpointName = @getTrimmedEndpointName asResourse, asAction
          @ApplicationModule::[vsEndpointName] ?
            @tryLoadEndpoint(vsEndpointName) ?
            @ApplicationModule::[vsTrimmedEndpointName] ?
            @tryLoadEndpoint(vsTrimmedEndpointName) ?
            @getStandardActionEndpoint asAction

      @initializeMixin()
