

###
```coffee
Module = require 'Module'

module.exports = (App)->
  App::CrudGateway extends Module::Gateway
    @inheritProtected()
    @include Module::CrudGatewayMixin

    @module App

  return App::CrudGateway.initialize()
```

```coffee
module.exports = (App)->
  App::PrepareModelCommand extends Module::SimpleCommand
    @public execute: Function,
      default: ->
        #...
        @facade.registerProxy App::CrudGateway.new 'DefaultGateway',
          entityName: null # какие-то конфиги и что-то опорное для подключения эндов
        @facade.registerProxy App::CrudGateway.new 'CucumbersGateway',
          entityName: 'cucumber'
          schema: App::CucumberRecord.schema
        @facade.registerProxy App::CrudGateway.new 'TomatosGateway',
          entityName: 'tomato'
          schema: App::TomatoRecord.schema
          endpoints: {
            changeColor: App::TomatosChangeColorEndpoint
          }
        @facade.registerProxy Module::Gateway.new 'AuthGateway',
          entityName: 'user'
          endpoints: {
            signin: App::AuthSigninEndpoint
            signout: App::AuthSignoutEndpoint
            whoami: App::AuthWhoamiEndpoint
          }
        #...
        return
```
###


module.exports = (Module)->
  {
    APPLICATION_MEDIATOR
    Utils: { inflect, extend }
  } = Module::
  class Gateway extends Module::Proxy
    @inheritProtected()
    # @implements Module::GatewayInterface
    @include Module::ConfigurableMixin
    @module Module

    ipoEndpoints = @private endpoints: Object
    ipsMultitonKey = @protected multitonKey: String

    @public ApplicationModule: Module::Class,
      get: ->
        if @[ipsMultitonKey]?
          @facade?.retrieveMediator? APPLICATION_MEDIATOR
            ?.getViewComponent?()
            ?.Module ? @Module
        else
          @Module

    ipsEndpointsPath = @private endpointsPath: String,
      get: -> "#{@ApplicationModule::ROOT}/endpoints"

    @public tryLoadEndpoint: Function,
      default: (asName) ->
        vsEndpointPath = "#{@[ipsEndpointsPath]}/#{asName}"
        try require(vsEndpointPath) @ApplicationModule

    @public getEndpointName: Function,
      default: (asResourse, asAction) ->
        vsResource = asResourse
          .replace /\//g, '_'
          .replace /\_+/g, '_'
        vsPath = "#{vsResource}_#{asAction}_endpoint"
        vsPath = vsPath.replace /\_+/g, '_'
        inflect.camelize vsPath

    @public getStandardActionEndpoint: Function,
      default: (asResourse, asAction) ->
        vsEndpointName = "#{inflect.camelize asAction}Endpoint"
        @ApplicationModule::[vsEndpointName] ? @ApplicationModule::Endpoint

    @public getEndpoint: Function,
      default: (asResourse, asAction) ->
        vsEndpointName = @getEndpointName asResourse, asAction
        @ApplicationModule::[vsEndpointName] ?
          @tryLoadEndpoint(vsEndpointName) ?
          @getStandardActionEndpoint asResourse, asAction

    @public swaggerDefinitionFor: Function,
      default: (asResourse, asAction, opts)->
        vcEndpoint = @getEndpoint asResourse, asAction
        options = extend {}, opts, gateway: @
        vcEndpoint.new options


  Gateway.initialize()
