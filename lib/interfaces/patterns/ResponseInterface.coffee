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

Stream = require 'stream'

module.exports = (Module)->
  {
    AnyT, NilT
    FuncG, UnionG, MaybeG
    SwitchInterface
    Interface
  } = Module::

  class ResponseInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual res: Object
    @virtual switch: SwitchInterface

    # @virtual socket: Object
    # @virtual header: Object
    # @virtual headers: Object

    # @virtual status: MaybeG Number
    # @virtual message: String
    # @virtual body: MaybeG UnionG String, Buffer, Object, Array, Number, Boolean, Stream
    # @virtual length: Number
    # @virtual headerSent: MaybeG Boolean
    @virtual vary: FuncG String
    @virtual redirect: FuncG [String, MaybeG String]
    @virtual attachment: FuncG String
    # @virtual lastModified: MaybeG Date
    # @virtual etag: String
    # @virtual type: MaybeG String
    @virtual is: FuncG [UnionG String, Array], UnionG String, Boolean, NilT
    @virtual get: FuncG String, UnionG String, Array
    @virtual set: FuncG [UnionG(String, Object), MaybeG AnyT]
    @virtual append: FuncG [String, UnionG String, Array]
    @virtual remove: FuncG String
    # @virtual writable: Boolean

    # @virtual toJSON: FuncG [], Object
    #
    # @virtual inspect: FuncG [], Object


    @initialize()
