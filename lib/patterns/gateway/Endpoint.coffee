

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

    @public tags: MaybeG Array
    @public headers: MaybeG Array
    @public pathParams: MaybeG Array
    @public queryParams: MaybeG Array
    @public payload: MaybeG Object
    @public responses: MaybeG Array
    @public errors: MaybeG Array
    @public title: MaybeG String
    @public synopsis: MaybeG String
    @public isDeprecated: Boolean,
      default: no

    @public tag: FuncG(String, EndpointInterface),
      default: (asName)->
        @tags ?= []
        @tags.push asName
        return @

    @public header: FuncG([String, JoiT, MaybeG String], EndpointInterface),
      default: (name, schema, description)->
        @headers ?= []
        @headers.push {name, schema, description}
        return @

    @public pathParam: FuncG([String, JoiT, MaybeG String], EndpointInterface),
      default: (name, schema, description)->
        @pathParams ?= []
        @pathParams.push {name, schema, description}
        return @

    @public queryParam: FuncG([String, JoiT, MaybeG String], EndpointInterface),
      default: (name, schema, description)->
        @queryParams ?= []
        @queryParams.push {name, schema, description}
        return @

    @public body: FuncG([JoiT, MaybeG(UnionG Array, String), MaybeG String], EndpointInterface),
      default: (schema, mimes, description)->
        @payload = {schema, mimes, description}
        return @

    @public response: FuncG([UnionG(Number, String, JoiT, NilT), MaybeG(UnionG JoiT, String, Array), MaybeG(UnionG Array, String), MaybeG String], EndpointInterface),
      default: (status, schema, mimes, description)->
        @responses ?= []
        @responses.push { status, schema, mimes, description }
        return @

    @public error: FuncG([UnionG(Number, String), MaybeG String], EndpointInterface),
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
