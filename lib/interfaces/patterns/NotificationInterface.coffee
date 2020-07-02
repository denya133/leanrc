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
    Interface
  } = Module::

  class NotificationInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual getName: FuncG [], String
    @virtual setBody: FuncG [MaybeG AnyT]
    @virtual getBody: FuncG [], MaybeG AnyT
    @virtual setType: FuncG String
    @virtual getType: FuncG [], MaybeG String


    @initialize()
