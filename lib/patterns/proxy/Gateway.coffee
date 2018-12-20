

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
    AnyT, PointerT, JoiT
    FuncG, SubsetG, DictG, ListG, MaybeG
    GatewayInterface, EndpointInterface
    ConfigurableMixin
    Utils: { inflect, assign, filesListSync }
  } = Module::

  class Gateway extends Module::Proxy
    @inheritProtected()
    @include ConfigurableMixin
    @implements GatewayInterface
    @module Module

    # ipsMultitonKey = Symbol.for '~multitonKey' #PointerT @protected multitonKey: String
    iplKnownEndpoints = PointerT @protected knownEndpoints: ListG String
    # ipcApplicationModule = PointerT @protected ApplicationModule: MaybeG SubsetG Module
    iphSchemas = PointerT @protected schemas: DictG String, MaybeG JoiT
    ipsEndpointsPath = PointerT @protected endpointsPath: String,
      get: -> "#{@ApplicationModule::ROOT}/endpoints"

    # @public ApplicationModule: SubsetG(Module),
    #   get: ->
    #     @[ipcApplicationModule] ?= if @[ipsMultitonKey]?
    #       @facade
    #         ?.retrieveMediator APPLICATION_MEDIATOR
    #         ?.getViewComponent()
    #         ?.Module ? @Module
    #     else
    #       @Module

    @public tryLoadEndpoint: FuncG(String, MaybeG SubsetG EndpointInterface),
      default: (asName) ->
        if asName in @[iplKnownEndpoints]
          vsEndpointPath = "#{@[ipsEndpointsPath]}/#{asName}"
          return try require(vsEndpointPath) @ApplicationModule
        return

    @public getEndpointByName: FuncG(String, MaybeG SubsetG EndpointInterface),
      default: (asName) ->
        (@ApplicationModule.NS ? @ApplicationModule::)[asName] ? @tryLoadEndpoint asName

    @public getEndpointName: FuncG([String, String], String),
      default: (asResourse, asAction) ->
        vsPath = "#{asResourse}_#{asAction}_endpoint"
          .replace /\//g, '_'
          .replace /\_+/g, '_'
        inflect.camelize vsPath

    @public getStandardActionEndpoint: FuncG([String, String], SubsetG EndpointInterface),
      default: (asResourse, asAction) ->
        vsEndpointName = "#{inflect.camelize asAction}Endpoint"
        (@ApplicationModule.NS ? @ApplicationModule::)[vsEndpointName] ? @ApplicationModule::Endpoint

    @public getEndpoint: FuncG([String, String], SubsetG EndpointInterface),
      default: (asResourse, asAction) ->
        vsEndpointName = @getEndpointName asResourse, asAction
        @getEndpointByName(vsEndpointName) ?
          @getStandardActionEndpoint asResourse, asAction

    @public swaggerDefinitionFor: FuncG([String, String, MaybeG Object], EndpointInterface),
      default: (asResourse, asAction, opts)->
        vcEndpoint = @getEndpoint asResourse, asAction
        options = assign {}, opts, gateway: @
        vcEndpoint.new options

    @public getSchema: FuncG(String, JoiT),
      default: (asRecordName) ->
        @[iphSchemas][asRecordName] ?= (@ApplicationModule.NS ? @ApplicationModule::)[asRecordName].schema
        @[iphSchemas][asRecordName]

    @public init: FuncG([String, MaybeG AnyT]),
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


    @initialize()
