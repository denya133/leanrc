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
    AnyT, NilT
    FuncG, UnionG, MaybeG
    RequestInterface, ResponseInterface, SwitchInterface, CookiesInterface
    Interface
  } = Module::

  class ContextInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual req: Object
    @virtual res: Object
    # @virtual request: MaybeG RequestInterface
    # @virtual response: MaybeG ResponseInterface
    # @virtual state: MaybeG Object
    @virtual switch: SwitchInterface
    # @virtual respond: MaybeG Boolean
    # @virtual routePath: MaybeG String
    # @virtual pathParams: MaybeG Object

    @virtual throw: FuncG [UnionG(String, Number), MaybeG(String), MaybeG Object]

    @virtual assert: FuncG [AnyT, MaybeG(UnionG String, Number), MaybeG(String), MaybeG Object]

    @virtual onerror: FuncG [MaybeG AnyT]

    # Request aliases
    # @virtual header: Object
    # @virtual headers: Object
    # @virtual method: String
    # @virtual url: String
    # @virtual originalUrl: String
    # @virtual origin: String
    # @virtual href: String
    # @virtual path: String
    # @virtual query: Object
    # @virtual querystring: String
    # @virtual host: String
    # @virtual hostname: String
    # @virtual fresh: Boolean
    # @virtual stale: Boolean
    # @virtual socket: Object
    # @virtual protocol: String
    # @virtual secure: Boolean
    # @virtual ip: String
    # @virtual ips: Array
    # @virtual subdomains: Array
    @virtual is: FuncG [UnionG String, Array], UnionG String, Boolean, NilT
    @virtual accepts: FuncG [MaybeG UnionG String, Array], UnionG String, Array, Boolean
    @virtual acceptsEncodings: FuncG [MaybeG UnionG String, Array], UnionG String, Array
    @virtual acceptsCharsets: FuncG [MaybeG UnionG String, Array], UnionG String, Array
    @virtual acceptsLanguages: FuncG [MaybeG UnionG String, Array], UnionG String, Array
    @virtual get: FuncG String, String

    # Response aliases
    # @virtual body: MaybeG UnionG String, Buffer, Object, Array, Number, Boolean, Stream
    # @virtual status: MaybeG Number
    # @virtual message: String
    # @virtual length: Number
    # @virtual type: MaybeG String
    # @virtual headerSent: MaybeG Boolean
    @virtual redirect: FuncG [String, MaybeG String]
    @virtual attachment: FuncG String
    @virtual set: FuncG [UnionG(String, Object), MaybeG AnyT]
    @virtual append: FuncG [String, UnionG String, Array]
    @virtual vary: FuncG String
    @virtual flushHeaders: Function
    @virtual remove: FuncG String
    # @virtual lastModified: MaybeG Date
    # @virtual etag: String

    # @virtual toJSON: FuncG [], Object
    #
    # @virtual inspect: FuncG [], Object


    @initialize()
