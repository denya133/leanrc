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
    AnyT, PointerT
    FuncG, SubsetG, MaybeG
    MediatorInterface, NotificationInterface, ProxyInterface
    Notifier
  } = Module::

  class Mediator extends Notifier
    @inheritProtected()
    @implements MediatorInterface
    @module Module

    ipsMediatorName = PointerT @private mediatorName: String
    ipoViewComponent = PointerT @private viewComponent: MaybeG AnyT

    @public getMediatorName: FuncG([], String),
      default: -> @[ipsMediatorName]

    @public getName: FuncG([], String),
      default: -> @[ipsMediatorName]

    @public getViewComponent: FuncG([], MaybeG AnyT),
      default: -> @[ipoViewComponent]

    @public setViewComponent: FuncG(AnyT),
      default: (aoViewComponent)->
        @[ipoViewComponent] = aoViewComponent
        return

    @public view: MaybeG(AnyT),
      get: -> @getViewComponent()
      set: (aoViewComponent)-> @setViewComponent aoViewComponent

    @public getProxy: FuncG(String, MaybeG ProxyInterface),
      default: (args...)-> @facade.retrieveProxy args...

    @public addProxy: FuncG(ProxyInterface),
      default: (args...)-> @facade.registerProxy args...

    @public listNotificationInterests: FuncG([], Array),
      default: -> []

    @public handleNotification: FuncG(NotificationInterface),
      default: -> return

    @public onRegister: Function,
      default: -> return

    @public onRemove: Function,
      default: -> return

    # need test it
    @public @static @async restoreObject: FuncG([SubsetG(Module), Object], MediatorInterface),
      default: (Module, replica)->
        if replica?.class is @name and replica?.type is 'instance'
          facade = Module::ApplicationFacade.getInstance replica.multitonKey
          mediator = facade.retrieveMediator replica.mediatorName
          yield return mediator
        else
          return yield @super Module, replica

    # need test it
    @public @static @async replicateObject: FuncG(MediatorInterface, Object),
      default: (instance)->
        replica = yield @super instance
        ipsMultitonKey = Symbol.for '~multitonKey'
        replica.multitonKey = instance[ipsMultitonKey]
        replica.mediatorName = instance.getMediatorName()
        yield return replica

    @public init: FuncG([MaybeG(String), MaybeG AnyT]),
      default: (asMediatorName, aoViewComponent)->
        @super arguments...
        @[ipsMediatorName] = asMediatorName ? @constructor.name
        @[ipoViewComponent] = aoViewComponent if aoViewComponent?
        return


    @initialize()
