

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
    Utils: { inflect, extend, filesListSync }
  } = Module::
  class Gateway extends Module::Proxy
    @inheritProtected()
    # @implements Module::GatewayInterface
    @include Module::ConfigurableMixin
    @module Module

    # ipoEndpoints = @private endpoints: Object
    ipsMultitonKey = @protected multitonKey: String
    iplKnownEndpoints = @protected knownEndpoints: Array
    ipcApplicationModule = @protected ApplicationModule: Module::Class
    iphSchemas = @private schemas: Object

    @public ApplicationModule: Module::Class,
      get: ->
        @[ipcApplicationModule] ?= if @[ipsMultitonKey]?
          @facade
            ?.retrieveMediator APPLICATION_MEDIATOR
            ?.getViewComponent()
            ?.Module ? @Module
        else
          @Module

    ipsEndpointsPath = @private endpointsPath: String,
      get: -> "#{@ApplicationModule::ROOT}/endpoints"

    @public tryLoadEndpoint: Function,
      default: (asName) ->
        if asName in @[iplKnownEndpoints]
          vsEndpointPath = "#{@[ipsEndpointsPath]}/#{asName}"
          return try require(vsEndpointPath) @ApplicationModule
        return

    @public getEndpointByName: Function,
      default: (asName) ->
        (@ApplicationModule.NS ? @ApplicationModule::)[asName] ? @tryLoadEndpoint asName

    @public getEndpointName: Function,
      default: (asResourse, asAction) ->
        vsPath = "#{asResourse}_#{asAction}_endpoint"
          .replace /\//g, '_'
          .replace /\_+/g, '_'
        inflect.camelize vsPath

    @public getStandardActionEndpoint: Function,
      default: (asResourse, asAction) ->
        vsEndpointName = "#{inflect.camelize asAction}Endpoint"
        (@ApplicationModule.NS ? @ApplicationModule::)[vsEndpointName] ? @ApplicationModule::Endpoint

    @public getEndpoint: Function,
      default: (asResourse, asAction) ->
        vsEndpointName = @getEndpointName asResourse, asAction
        @getEndpointByName(vsEndpointName) ?
          @getStandardActionEndpoint asResourse, asAction

    @public swaggerDefinitionFor: Function,
      default: (asResourse, asAction, opts)->
        vcEndpoint = @getEndpoint asResourse, asAction
        options = extend {}, opts, gateway: @
        vcEndpoint.new options

    @public getSchema: Function,
      default: (asRecordName) ->
        @[iphSchemas][asRecordName] ?= (@ApplicationModule.NS ? @ApplicationModule::)[asRecordName].schema
        @[iphSchemas][asRecordName]

    @public init: Function,
      default: (args...) ->
        @super args...
        @[iphSchemas] = {}
        vPostfixMask = /\.(js|coffee)$/
        vlKnownEndpoints = try filesListSync @[ipsEndpointsPath]
        @[iplKnownEndpoints] = if vlKnownEndpoints?
          vlKnownEndpoints
            .filter (asFileName) -> vPostfixMask.test asFileName
            .map (asFileName) -> asFileName.replace vPostfixMask, ''
        else
          []
        return


  Gateway.initialize()
