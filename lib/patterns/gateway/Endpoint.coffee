

module.exports = (Module)->
  {
    JoiT, NilT
    FuncG, InterfaceG, DictG, MaybeG, UnionG
    EndpointInterface
    GatewayInterface
    CoreObject
  } = Module::

  class Endpoint extends CoreObject
    @inheritProtected()
    @implements EndpointInterface
    @module Module

    @public @static keyNames: DictG(String, MaybeG String),
      default: {}
    @public @static itemEntityNames: DictG(String, MaybeG String),
      default: {}
    @public @static listEntityNames: DictG(String, MaybeG String),
      default: {}
    @public @static itemSchemas: DictG(String, MaybeG JoiT),
      default: {}
    @public @static listSchemas: DictG(String, MaybeG JoiT),
      default: {}

    @public gateway: GatewayInterface

    @public tags: Array
    @public headers: Array
    @public pathParams: Array
    @public queryParams: Array
    @public payload: Object
    @public responses: Array
    @public errors: Array
    @public title: String
    @public synopsis: String
    @public isDeprecated: Boolean,
      default: no

    @public tag: FuncG(String, EndpointInterface),
      default: (asName)->
        @tags ?= []
        @tags.push asName
        return @

    @public header: FuncG([String, Object, MaybeG String], EndpointInterface),
      default: (name, schema, description)->
        @headers ?= []
        @headers.push {name, schema, description}
        return @

    @public pathParam: FuncG([String, Object, MaybeG String], EndpointInterface),
      default: (name, schema, description)->
        @pathParams ?= []
        @pathParams.push {name, schema, description}
        return @

    @public queryParam: FuncG([String, Object, MaybeG String], EndpointInterface),
      default: (name, schema, description)->
        @queryParams ?= []
        @queryParams.push {name, schema, description}
        return @

    @public body: FuncG([Object, MaybeG(Array), MaybeG String], EndpointInterface),
      default: (schema, mimes, description)->
        @payload = {schema, mimes, description}
        return @

    @public response: FuncG([UnionG(Number, String), MaybeG(JoiT), MaybeG(Array), MaybeG String], EndpointInterface),
      default: (status, schema, mimes, description)->
        @responses ?= []
        @responses.push { status, schema, mimes, description }
        return @

    @public error: FuncG([UnionG(Number, String), String], EndpointInterface),
      default: (status, description)->
        @errors ?= []
        @errors.push {status, description}
        return @

    @public summary: FuncG(String, EndpointInterface),
      default: (asSummary)->
        @title = asSummary
        return @

    @public description: FuncG(String, EndpointInterface),
      default: (asDescription)->
        @synopsis = asDescription
        return @

    @public deprecated: FuncG(Boolean, EndpointInterface),
      default: (abDeprecated)->
        @isDeprecated = abDeprecated
        return @

    @public @static @async restoreObject: Function,
      default: ->
        throw new Error "restoreObject method not supported for #{@name}"
        yield return

    @public @static @async replicateObject: Function,
      default: ->
        throw new Error "replicateObject method not supported for #{@name}"
        yield return

    @public init: FuncG(InterfaceG(gateway: GatewayInterface), NilT),
      default: (args...) ->
        @super args...
        [ options ] = args
        { @gateway } = options
        return


    @initialize()
