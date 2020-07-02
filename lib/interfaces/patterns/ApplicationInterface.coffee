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
    FuncG, StructG, MaybeG
    ContextInterface
    ResourceInterface
    Interface
  } = Module::

  class ApplicationInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual @static NAME: String

    @virtual isLightweight: Boolean
    @virtual context: MaybeG ContextInterface

    @virtual start: Function
    @virtual finish: Function
    @virtual @async migrate: FuncG [MaybeG StructG until: MaybeG String]
    @virtual @async rollback: FuncG [MaybeG StructG {
      steps: MaybeG(Number), until: MaybeG String
    }]
    @virtual @async run: FuncG [String, MaybeG AnyT], MaybeG(AnyT)
    @virtual @async execute: FuncG [String, StructG({
      context: ContextInterface, reverse: String
    }), String], StructG {
      result: MaybeG(AnyT), resource: ResourceInterface
    }


    @initialize()
