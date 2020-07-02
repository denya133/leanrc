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
    AnyT
    FuncG, MaybeG
    CollectionInterface
    CursorInterface: CursorInterfaceDef
    Interface
  } = Module::

  class CursorInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual setCollection: FuncG CollectionInterface, CursorInterfaceDef

    @virtual setIterable: FuncG AnyT, CursorInterfaceDef

    @virtual @async toArray: FuncG [], Array

    @virtual @async next: FuncG [], MaybeG AnyT

    @virtual @async hasNext: FuncG [], Boolean

    @virtual @async close: Function

    @virtual @async count: FuncG [], Number

    @virtual @async forEach: FuncG Function

    @virtual @async map: FuncG Function, Array

    @virtual @async filter: FuncG Function, Array

    @virtual @async find: FuncG Function, AnyT

    @virtual @async compact: FuncG [], Array

    @virtual @async reduce: FuncG [Function, AnyT], AnyT

    @virtual @async first: FuncG [], MaybeG  AnyT


    @initialize()
