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
    FuncG, MaybeG, InterfaceG
    FacadeInterface
    Interface
  } = Module::

  class DelayableInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual @static delay: FuncG [
      FacadeInterface
      MaybeG InterfaceG queue: MaybeG(String), delayUntil: MaybeG Number
    ]

    @virtual delay: FuncG [
      FacadeInterface
      MaybeG InterfaceG queue: MaybeG(String), delayUntil: MaybeG Number
    ]


    @initialize()
