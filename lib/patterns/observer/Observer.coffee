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
    AnyT, PointerT, LambdaT
    FuncG, MaybeG
    ObserverInterface, NotificationInterface
    CoreObject
  } = Module::

  class Observer extends CoreObject
    @inheritProtected()
    @implements ObserverInterface
    @module Module

    ipoNotify = PointerT @private notify: MaybeG Function
    ipoContext = PointerT @private context: MaybeG AnyT

    @public setNotifyMethod: FuncG(Function),
      default: (amNotifyMethod)->
        @[ipoNotify] = amNotifyMethod
        return

    @public setNotifyContext: FuncG(AnyT),
      default: (aoNotifyContext)->
        @[ipoContext] = aoNotifyContext
        return

    @public getNotifyMethod: FuncG([], MaybeG Function),
      default: -> @[ipoNotify]

    @public getNotifyContext: FuncG([], MaybeG AnyT),
      default: -> @[ipoContext]

    @public compareNotifyContext: FuncG(AnyT, Boolean),
      default: (object)->
        object is @[ipoContext]

    @public notifyObserver: FuncG(NotificationInterface),
      default: (notification)->
        @getNotifyMethod().call @getNotifyContext(), notification
        return

    @public @static @async restoreObject: Function,
      default: ->
        throw new Error "restoreObject method not supported for #{@name}"
        yield return

    @public @static @async replicateObject: Function,
      default: ->
        throw new Error "replicateObject method not supported for #{@name}"
        yield return

    @public init: FuncG([MaybeG(Function), MaybeG AnyT]),
      default: (amNotifyMethod, aoNotifyContext)->
        @super arguments...
        @setNotifyMethod amNotifyMethod if amNotifyMethod
        @setNotifyContext aoNotifyContext if aoNotifyContext
        return


    @initialize()
