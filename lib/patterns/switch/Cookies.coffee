# This file is part of LeanRC.
#
# LeanRC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# LeanRC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with LeanRC.  If not, see <https://www.gnu.org/licenses/>.

module.exports = (Module)->
  {
    AnyT, PointerT
    FuncG, MaybeG, StructG
    CookiesInterface
    CoreObject
    Utils: { isArangoDB }
  } = Module::

  class Cookies extends CoreObject
    @inheritProtected()
    @implements CookiesInterface
    @module Module

    ipoCookies = PointerT @protected cookies: Object

    @public request: Object
    @public response: Object
    @public key: String

    @public get: FuncG([String, MaybeG Object], MaybeG String),
      default: (name, opts)->
        if isArangoDB()
          if opts? and opts.signed
            @request.cookie name, {secret: @key, algorithm: 'sha256'}
          else
            @request.cookie name
        else
          @[ipoCookies].get name, opts

    @public set: FuncG([String, AnyT, MaybeG Object], CookiesInterface),
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

    @public init: FuncG([Object, Object, MaybeG StructG {
      key: MaybeG String
      secure: MaybeG Boolean
    }]),
      default: (request, response, {key, secure} = {})->
        @super()
        @request = request
        @response = response
        key ?= 'secret'
        secure ?= no
        @key = key
        unless isArangoDB()
          Keygrip = require 'keygrip'
          NodeCookies = require 'cookies'
          keys = new Keygrip [key], 'sha256', 'hex'
          @[ipoCookies] = new NodeCookies request, response, {keys, secure}
        return


    @initialize()
