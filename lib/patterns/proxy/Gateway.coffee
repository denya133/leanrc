

###
```coffee
Module = require 'Module'

module.exports = (App)->
  App::CrudGateway extends Module::Gateway
    @inheritProtected()
    @include Module::CrudEndpointsMixin

    @Module: App

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
            changeColor: App::TomatosChangeColorEndpoint.new()
          }
        @facade.registerProxy Module::Gateway.new 'AuthGateway',
          entityName: 'user'
          endpoints: {
            signin: App::AuthSigninEndpoint.new()
            signout: App::AuthSignoutEndpoint.new()
            whoami: App::AuthWhoamiEndpoint.new()
          }
        #...
        return
```
###


module.exports = (Module)->
  class Gateway extends Module::Proxy
    @inheritProtected()
    @implements Module::GatewayInterface

    @Module: Module

    ipoEndpoints = @private endpoints: Object

    @public swaggerDefinition: Function,
      args: [String, Function]
      return: Module::NILL
      default: (asAction, lambda = (aoData)-> aoData)->
        voEndpoint = lambda.apply @, [Module::Endpoint.new(gateway: @)]
        @[ipoEndpoints] ?= {}
        @[ipoEndpoints][asAction] = voEndpoint
        return

    @public swaggerDefinitionFor: Function,
      args: [String]
      return: Module::EndpointInterface
      default: (asAction)-> @[ipoEndpoints]?[asAction]

    @public onRegister: Function,
      default: (args...)->
        @super args...
        {endpoints} = @getData()
        @[ipoEndpoints] = Module::Utils.extend {}, (@[ipoEndpoints] ? {}), endpoints
        return


  Gateway.initialize()
