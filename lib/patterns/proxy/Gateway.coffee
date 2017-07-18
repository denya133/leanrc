

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
  class Gateway extends Module::Proxy
    @inheritProtected()
    @implements Module::GatewayInterface
    @include Module::ConfigurableMixin
    @module Module

    ipoEndpoints = @private endpoints: Object

    @public swaggerDefinition: Function,
      default: (asAction, lambda = ((aoData)-> aoData), force = no)->
        voEndpoint = lambda.apply @, [Module::Endpoint.new(gateway: @)]
        @[ipoEndpoints] ?= {}
        if force or not @[ipoEndpoints][asAction]?
          @[ipoEndpoints][asAction] = voEndpoint
        return

    @public registerEndpoints: Function,
      default: (ahConfig)->
        @[ipoEndpoints] ?= {}
        for own asAction, aoEndpoint of ahConfig
          @[ipoEndpoints][asAction] = aoEndpoint
        return

    @public swaggerDefinitionFor: Function,
      default: (asAction)-> @[ipoEndpoints]?[asAction]

    @public onRegister: Function,
      default: (args...)->
        @super args...
        {endpoints} = @getData() ? {}
        if endpoints?
          @[ipoEndpoints] ?= {}
          for own asAction, acEndpoint of endpoints
            @[ipoEndpoints][asAction] = acEndpoint.new gateway: @
        return


  Gateway.initialize()
