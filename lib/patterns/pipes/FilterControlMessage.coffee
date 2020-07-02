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
    PointerT, LambdaT
    FuncG, MaybeG
    PipeMessage
  } = Module::

  class FilterControlMessage extends PipeMessage
    @inheritProtected()

    @module Module

    @public @static BASE: String,
      get: -> "#{PipeMessage.BASE}filter-control/"
    @public @static SET_PARAMS: String,
      get: -> "#{@BASE}setparams"
    @public @static SET_FILTER: String,
      get: -> "#{@BASE}setfilter"
    @public @static BYPASS: String,
      get: -> "#{@BASE}bypass"
    @public @static FILTER: String,
      get: -> "#{@BASE}filter"

    ipsName = PointerT @protected name: String
    ipmFilter = PointerT @protected filter: LambdaT
    ipoParams = PointerT @protected params: Object

    @public setName: FuncG(String),
      default: (asName)->
        @[ipsName] = asName
        return

    @public getName: FuncG([], String),
      default: -> @[ipsName]

    @public setFilter: FuncG(Function),
      default: (amFilter)->
        @[ipmFilter] = amFilter
        return

    @public getFilter: FuncG([], Function),
      default: -> @[ipmFilter]

    @public setParams: FuncG(Object),
      default: (aoParams)->
        @[ipoParams] = aoParams
        return

    @public getParams: FuncG([], Object),
      default: -> @[ipoParams]

    @public init: FuncG([
      String, String, MaybeG(Function), MaybeG Object
    ]),
      default: (asType, asName, amFilter=null, aoParams=null)->
        @super asType
        @setName asName
        @setFilter amFilter if amFilter?
        @setParams aoParams if aoParams?
        return


    @initialize()
