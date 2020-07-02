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
    NotifierInterface
    FacadeInterface
    CoreObject
  } = Module::

  class Notifier extends CoreObject
    @inheritProtected()
    @implements NotifierInterface
    @module Module

    @const MULTITON_MSG: "multitonKey for this Notifier not yet initialized!"

    ipsMultitonKey = PointerT @protected multitonKey: MaybeG String
    ipcApplicationModule = PointerT @protected ApplicationModule: MaybeG SubsetG Module

    @public facade: FacadeInterface,
      get: ->
        unless @[ipsMultitonKey]?
          throw new Error Notifier::MULTITON_MSG
        Module::Facade.getInstance @[ipsMultitonKey]

    @public sendNotification: FuncG([String, MaybeG(AnyT), MaybeG String]),
      default: (asName, aoBody, asType)->
        @facade?.sendNotification asName, aoBody, asType
        return

    @public send: FuncG([String, MaybeG(AnyT), MaybeG String]),
      default: (args...)-> @sendNotification args...

    @public initializeNotifier: FuncG(String),
      default: (asKey)->
        @[ipsMultitonKey] = asKey
        return

    @public ApplicationModule: SubsetG(Module),
      get: ->
        @[ipcApplicationModule] ?= if @[ipsMultitonKey]?
          Module::Facade.getInstance @[ipsMultitonKey]
            ?.retrieveMediator Module::APPLICATION_MEDIATOR
            ?.getViewComponent()
            ?.Module ? @Module
        else
          @Module


    @initialize()
