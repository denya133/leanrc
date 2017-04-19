RC            = require 'RC'


###
```coffee
LeanRC = require 'LeanRC'

module.exports = (App)->
  App::CrudGateway extends LeanRC::Gateway
    @inheritProtected()
    @include LeanRC::CrudEndpointsMixin

    @Module: App

  return App::CrudGateway.initialize()
```

```coffee
module.exports = (App)->
  App::PrepareModelCommand extends LeanRC::SimpleCommand
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
        @facade.registerProxy LeanRC::Gateway.new 'AuthGateway',
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

module.exports = (LeanRC)->
  class LeanRC::Gateway extends LeanRC::Proxy
    @inheritProtected()
    @implements LeanRC::GatewayInterface

    @Module: LeanRC

    ipoEndpoints = @private _endpoints: Object

    @public swaggerDefinition: Function,
      args: [String, Function]
      return: RC::Constants.NILL
      default: (asAction, lambda = (aoData)-> aoData)->
        voEndpoint = lambda.apply @, [LeanRC::Endpoint.new(gateway: @)]
        @[ipoEndpoints] ?= {}
        @[ipoEndpoints][asAction] = voEndpoint
        return

    @public swaggerDefinitionFor: Function,
      args: [String]
      return: LeanRC::EndpointInterface
      default: (asAction)-> @[ipoEndpoints]?[asAction]

    @public onRegister: Function,
      default: (args...)->
        @super args...
        {endpoints} = @getData()
        @[ipoEndpoints] = RC::Utils.extend {}, (@[ipoEndpoints] ? {}), endpoints
        return


  return LeanRC::Gateway.initialize()
