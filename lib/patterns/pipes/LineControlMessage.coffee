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
    FuncG, MaybeG
    PipeMessage
  } = Module::

  class LineControlMessage extends PipeMessage
    @inheritProtected()

    @module Module

    @public @static BASE: String,
      get: -> "#{PipeMessage.BASE}queue/"
    @public @static FLUSH: String,
      get: -> "#{@BASE}flush"
    @public @static SORT: String,
      get: -> "#{@BASE}sort"
    @public @static FIFO: String,
      get: -> "#{@BASE}fifo"

    @public init: FuncG([
      String, MaybeG(Object), MaybeG(Object), MaybeG Number
    ]),
      default: (asType)->
        @super asType
        return


    @initialize()
