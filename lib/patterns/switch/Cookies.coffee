

module.exports = (Module)->
  {
    ANY

    CoreObject
    CookiesInterface
    Utils
  } = Module::
  { isArangoDB } = Utils

  class Cookies extends CoreObject
    @inheritProtected()
    # @implements CookiesInterface
    @module Module

    ipoCookies = @protected cookies: Object

    @public request: Object
    @public response: Object
    @public key: String

    @public get: Function,
      default: (name, opts)->
        if isArangoDB()
          if opts? and opts.signed
            @request.cookie name, {secret: @key, algorithm: 'sha256'}
          else
            @request.cookie name
        else
          @[ipoCookies].get name, opts

    @public set: Function,
      default: (name, value, opts)->
        if isArangoDB()
          if opts?
            _opts = {}
            _opts.ttl = (opts.maxAge / 1000) if opts.maxAge?
            _opts.path = opts.path if opts.path?
            _opts.domain = opts.domain if opts.domain?
            _opts.secure = opts.secure if opts.secure?
            _opts.httpOnly = opts.httpOnly if opts.httpOnly?
            if opts.signed
              _opts.secret = @key
              _opts.algorithm = 'sha256'
            @response.cookie name, value, _opts
          else
            @response.cookie name, value
        else
          @[ipoCookies].set name, value, opts
        return @

    @public @static @async restoreObject: Function,
      default: ->
        throw new Error "restoreObject method not supported for #{@name}"
        yield return

    @public @static @async replicateObject: Function,
      default: ->
        throw new Error "replicateObject method not supported for #{@name}"
        yield return

    @public init: Function,
      default: (request, response, {key, secure} = {})->
        @super()
        @request = request
        @response = response
        @key = key
        unless isArangoDB()
          Keygrip = require 'keygrip'
          NodeCookies = require 'cookies'
          keys = new Keygrip [key], 'sha256', 'hex'
          @[ipoCookies] = new NodeCookies request, response, {keys, secure}
        return


  Cookies.initialize()
