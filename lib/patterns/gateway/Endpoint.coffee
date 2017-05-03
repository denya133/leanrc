

module.exports = (Module)->
  class Endpoint extends Module::CoreObject
    @inheritProtected()
    @module Module
    @implements Module::EndpointInterface

    @public gateway: Module::GatewayInterface

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

    @public tag: Function,
      default: (asName)->
        @tags ?= []
        @tags.push asName
        return @

    @public header: Function,
      default: (name, schema, description)->
        @headers ?= []
        @headers.push {name, schema, description}
        return @

    @public pathParam: Function,
      default: (name, schema, description)->
        @pathParams ?= []
        @pathParams.push {name, schema, description}
        return @

    @public queryParam: Function,
      default: (name, schema, description)->
        @queryParams ?= []
        @queryParams.push {name, schema, description}
        return @

    @public body: Function,
      default: (schema, mimes, description)->
        @payload = {schema, mimes, description}
        return @

    @public response: Function,
      default: (status, schema, mimes, description)->
        @responses ?= []
        @responses.push {status, schema, mimes, description}
        return @

    @public error: Function,
      default: (status, description)->
        @errors ?= []
        @errors.push {status, description}
        return @

    @public summary: Function,
      default: (asSummary)->
        @title = asSummary
        return @

    @public description: Function,
      default: (asDescription)->
        @synopsis = asDescription
        return @

    @public deprecated: Function,
      default: (abDeprecated)->
        @isDeprecated = abDeprecated
        return @

    @public init: Function,
      default: ({@gateway})->
        @super arguments...


  Endpoint.initialize()
