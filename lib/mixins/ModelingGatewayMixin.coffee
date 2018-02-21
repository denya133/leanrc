

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
    Gateway
    Utils: { _, inflect, joi, statuses }
  } = Module::

  HTTP_NOT_FOUND    = statuses 'not found'
  HTTP_CONFLICT     = statuses 'conflict'
  UNAUTHORIZED      = statuses 'unauthorized'
  FORBIDDEN         = statuses 'forbidden'
  UPGRADE_REQUIRED  = statuses 'upgrade required'

  Module.defineMixin 'ModelingGatewayMixin', (BaseClass = Gateway) ->
    class extends BaseClass
      @inheritProtected()
      # @implements Module::ModelingGatewayMixinInterface

      @public getStandardActionEndpoint: Function,
        default: (asResourse, asAction) ->
          vsEndpointName = if _.startsWith asResourse.toLowerCase(), 'modeling'
            "Modeling#{inflect.camelize asAction}Endpoint"
          else
            "#{inflect.camelize asAction}Endpoint"
          @ApplicationModule::[vsEndpointName] ? @ApplicationModule::Endpoint

      @initializeMixin()
