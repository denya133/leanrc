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
    LambdaT, PointerT
    FuncG, MaybeG
    PipeFittingInterface, PipeMessageInterface
    CoreObject
  } = Module::

  class PipeListener extends CoreObject
    @inheritProtected()
    @implements PipeFittingInterface
    @module Module

    ipoContext = PointerT @private context: Object
    ipmListener = PointerT @private listener: LambdaT

    @public connect: FuncG(PipeFittingInterface, Boolean),
      default: ->
        return no

    @public disconnect: FuncG([], MaybeG PipeFittingInterface),
      default: ->
        return null

    @public write: FuncG(PipeMessageInterface, Boolean),
      default: (aoMessage)->
        @[ipmListener].call @[ipoContext], aoMessage
        return yes

    @public @static @async restoreObject: Function,
      default: ->
        throw new Error "restoreObject method not supported for #{@name}"
        yield return

    @public @static @async replicateObject: Function,
      default: ->
        throw new Error "replicateObject method not supported for #{@name}"
        yield return

    @public init: FuncG([Object, Function]),
      default: (aoContext, amListener)->
        @super arguments...
        @[ipoContext] = aoContext
        @[ipmListener] = amListener
        return


    @initialize()
