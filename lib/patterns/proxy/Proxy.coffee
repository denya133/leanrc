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
    ProxyInterface
    Notifier
  } = Module::

  class Proxy extends Notifier
    @inheritProtected()
    @implements ProxyInterface
    @module Module

    ipsProxyName = PointerT @private proxyName: String
    ipoData = PointerT @private data: MaybeG AnyT

    @public getProxyName: FuncG([], String),
      default: -> @[ipsProxyName]

    @public getName: FuncG([], String),
      default: -> @[ipsProxyName]

    @public setData: FuncG(AnyT),
      default: (ahData)->
        @[ipoData] = ahData
        return

    @public getData: FuncG([], MaybeG AnyT),
      default: -> @[ipoData]

    @public onRegister: Function,
      default: -> return

    @public onRemove: Function,
      default: -> return

    # need test it
    @public @static @async restoreObject: FuncG([SubsetG(Module), Object], ProxyInterface),
      default: (Module, replica)->
        if replica?.class is @name and replica?.type is 'instance'
          facade = Module::ApplicationFacade.getInstance replica.multitonKey
          proxy = facade.retrieveProxy replica.proxyName
          yield return proxy
        else
          return yield @super Module, replica

    # need test it
    @public @static @async replicateObject: FuncG(ProxyInterface, Object),
      default: (instance)->
        replica = yield @super instance
        ipsMultitonKey = Symbol.for '~multitonKey'
        replica.multitonKey = instance[ipsMultitonKey]
        replica.proxyName = instance.getProxyName()
        yield return replica

    @public init: FuncG([MaybeG(String), MaybeG AnyT]),
      default: (asProxyName, ahData)->
        @super arguments...

        @[ipsProxyName] = asProxyName ? @constructor.name

        if ahData?
          @setData ahData
        return


    @initialize()
