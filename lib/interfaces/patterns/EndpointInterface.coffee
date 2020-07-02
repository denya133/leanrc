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
    JoiT, NilT
    FuncG, MaybeG, UnionG
    GatewayInterface
    EndpointInterface: EndpointInterfaceDef
    Interface
  } = Module::

  class EndpointInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual gateway: GatewayInterface

    @virtual tags: MaybeG Array
    @virtual headers: MaybeG Array
    @virtual pathParams: MaybeG Array
    @virtual queryParams: MaybeG Array
    @virtual payload: MaybeG Object
    @virtual responses: MaybeG Array
    @virtual errors: MaybeG Array
    @virtual title: MaybeG String
    @virtual synopsis: MaybeG String
    @virtual isDeprecated: Boolean

    @virtual tag: FuncG String, EndpointInterfaceDef
    @virtual header: FuncG [String, JoiT, MaybeG String], EndpointInterfaceDef
    @virtual pathParam: FuncG [String, JoiT, MaybeG String], EndpointInterfaceDef
    @virtual queryParam: FuncG [String, JoiT, MaybeG String], EndpointInterfaceDef
    @virtual body: FuncG [JoiT, MaybeG(UnionG Array, String), MaybeG String], EndpointInterfaceDef
    @virtual response: FuncG [UnionG(Number, String, JoiT, NilT), MaybeG(UnionG JoiT, String, Array), MaybeG(UnionG Array, String), MaybeG String], EndpointInterfaceDef
    @virtual error: FuncG [UnionG(Number, String), MaybeG String], EndpointInterfaceDef
    @virtual summary: FuncG String, EndpointInterfaceDef
    @virtual description: FuncG String, EndpointInterfaceDef
    @virtual deprecated: FuncG Boolean, EndpointInterfaceDef


    @initialize()
