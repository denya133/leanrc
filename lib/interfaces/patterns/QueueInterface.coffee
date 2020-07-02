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
    FuncG, MaybeG, UnionG, ListG
    ResqueInterface
    Interface
  } = Module::

  class QueueInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual resque: ResqueInterface
    @virtual name: String
    @virtual concurrency: Number

    @virtual @async delay: FuncG [String, AnyT, MaybeG Number], UnionG String, Number

    @virtual @async push: FuncG [String, AnyT, MaybeG Number], UnionG String, Number

    @virtual @async get: FuncG [UnionG String, Number], MaybeG Object

    @virtual @async delete: FuncG [UnionG String, Number], Boolean

    @virtual @async abort: FuncG [UnionG String, Number]

    @virtual @async all: FuncG [MaybeG String], ListG Object

    @virtual @async pending: FuncG [MaybeG String], ListG Object

    @virtual @async progress: FuncG [MaybeG String], ListG Object

    @virtual @async completed: FuncG [MaybeG String], ListG Object

    @virtual @async failed: FuncG [MaybeG String], ListG Object


    @initialize()
