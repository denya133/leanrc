

###
```coffee
Module = require 'Module'

module.exports = (App)->
  App::ModelingGateway extends Module::Gateway
    @inheritProtected()
    @include Module::ModelingGatewayMixin

    @module App

  return App::ModelingGateway.initialize()
```

###

module.exports = (Module)->
  {
    FuncG, SubsetG
    EndpointInterface
    Gateway, Mixin
    Utils: { _, inflect, joi, statuses }
  } = Module::

  HTTP_NOT_FOUND    = statuses 'not found'
  HTTP_CONFLICT     = statuses 'conflict'
  UNAUTHORIZED      = statuses 'unauthorized'
  FORBIDDEN         = statuses 'forbidden'
  UPGRADE_REQUIRED  = statuses 'upgrade required'

  Module.defineMixin Mixin 'ModelingGatewayMixin', (BaseClass = Gateway) ->
    class extends BaseClass
      @inheritProtected()

      @public getStandardActionEndpoint: FuncG([String, String], SubsetG EndpointInterface),
        default: (asResourse, asAction) ->
          vsEndpointName = if _.startsWith asResourse.toLowerCase(), 'modeling'
            "Modeling#{inflect.camelize asAction}Endpoint"
          else
            "#{inflect.camelize asAction}Endpoint"
          @ApplicationModule::[vsEndpointName] ? @ApplicationModule::Endpoint

      @initializeMixin()
