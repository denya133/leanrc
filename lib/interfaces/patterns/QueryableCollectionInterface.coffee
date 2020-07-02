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

# методы `parseQuery` и `executeQuery` должны быть реализованы в миксинах в отдельных подлючаемых npm-модулях т.к. будут содержать некоторый платформозависимый код.

module.exports = (Module)->
  {
    FuncG, UnionG, MaybeG
    QueryInterface
    CursorInterface
    Interface
  } = Module::

  class QueryableCollectionInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual @async deleteBy: FuncG Object

    @virtual @async destroyBy: FuncG Object
    # NOTE: обращается к БД
    @virtual @async removeBy: FuncG Object

    @virtual @async findBy: FuncG [Object, MaybeG Object], CursorInterface
    # NOTE: обращается к БД
    @virtual @async takeBy: FuncG [Object, MaybeG Object], CursorInterface

    @virtual @async updateBy: FuncG [Object, Object]
    # NOTE: обращается к БД
    @virtual @async patchBy: FuncG [Object, Object]

    @virtual @async exists: FuncG Object, Boolean

    @virtual @async query: FuncG [UnionG Object, QueryInterface], CursorInterface

    @virtual @async parseQuery: FuncG(
      [UnionG Object, QueryInterface]
      UnionG Object, String, QueryInterface
    )

    @virtual @async executeQuery: FuncG(
      [UnionG Object, String, QueryInterface]
      CursorInterface
    )


    @initialize()
