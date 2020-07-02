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
    APPLICATION_MEDIATOR
    PointerT
    FuncG, SubsetG, DictG, MaybeG
    ControllerInterface, ViewInterface, CommandInterface, NotificationInterface
    CoreObject, Facade
    Utils: { _ }
  } = Module::

  class Controller extends CoreObject
    @inheritProtected()
    @implements ControllerInterface
    @module Module

    @const MULTITON_MSG: "Controller instance for this multiton key already constructed!"

    ipoView         = PointerT @private view: ViewInterface
    iphCommandMap   = PointerT @private commandMap: DictG String, MaybeG SubsetG CommandInterface
    iphClassNames   = PointerT @private classNames: DictG String, MaybeG String
    ipsMultitonKey  = PointerT @protected multitonKey: MaybeG String
    cphInstanceMap  = PointerT @private @static _instanceMap: DictG(String, MaybeG ControllerInterface),
      default: {}
    ipcApplicationModule = PointerT @protected ApplicationModule: MaybeG SubsetG Module

    @public ApplicationModule: SubsetG(Module),
      get: ->
        @[ipcApplicationModule] ?= if @[ipsMultitonKey]?
          Facade.getInstance @[ipsMultitonKey]
            ?.retrieveMediator APPLICATION_MEDIATOR
            ?.getViewComponent()
            ?.Module ? @Module
        else
          @Module

    @public @static getInstance: FuncG(String, ControllerInterface),
      default: (asKey)->
        unless Controller[cphInstanceMap][asKey]?
          Controller[cphInstanceMap][asKey] = Controller.new asKey
        Controller[cphInstanceMap][asKey]

    @public @static removeController: FuncG(String),
      default: (asKey)->
        if (voController = Controller[cphInstanceMap][asKey])?
          for asNotificationName in Reflect.ownKeys voController[iphCommandMap]
            voController.removeCommand asNotificationName
          Controller[cphInstanceMap][asKey] = undefined
          delete Controller[cphInstanceMap][asKey]
        return

    @public executeCommand: FuncG(NotificationInterface),
      default: (aoNotification)->
        vsName = aoNotification.getName()
        vCommand = @[iphCommandMap][vsName]
        unless vCommand?
          unless _.isEmpty vsClassName = @[iphClassNames][vsName]
            vCommand = @[iphCommandMap][vsName] = (@ApplicationModule.NS ? @ApplicationModule::)[vsClassName]
        if vCommand?
          voCommand = vCommand.new()
          voCommand.initializeNotifier @[ipsMultitonKey]
          voCommand.execute aoNotification
        return

    @public registerCommand: FuncG([String, SubsetG CommandInterface]),
      default: (asNotificationName, aCommand)->
        unless @[iphCommandMap][asNotificationName]
          @[ipoView].registerObserver asNotificationName, Module::Observer.new(@executeCommand, @)
          @[iphCommandMap][asNotificationName] = aCommand
        return

    @public addCommand: FuncG([String, SubsetG CommandInterface]),
      default: (args...)-> @registerCommand args...

    @public lazyRegisterCommand: FuncG([String, MaybeG String]),
      default: (asNotificationName, asClassName)->
        asClassName ?= asNotificationName
        unless @[iphCommandMap][asNotificationName]
          @[ipoView].registerObserver asNotificationName, Module::Observer.new(@executeCommand, @)
          @[iphClassNames][asNotificationName] = asClassName
        return

    @public hasCommand: FuncG(String, Boolean),
      default: (asNotificationName)->
        @[iphCommandMap][asNotificationName]? or @[iphClassNames][asNotificationName]?

    @public removeCommand: FuncG(String),
      default: (asNotificationName)->
        if @hasCommand(asNotificationName)
          @[ipoView].removeObserver asNotificationName, @
          @[iphCommandMap][asNotificationName] = undefined
          @[iphClassNames][asNotificationName] = undefined
          delete @[iphCommandMap][asNotificationName]
          delete @[iphClassNames][asNotificationName]
        return

    @public initializeController: Function,
      default: ->
        @[ipoView] = Module::View.getInstance @[ipsMultitonKey]
        return

    @public init: FuncG(String),
      default: (asKey)->
        @super arguments...
        if Controller[cphInstanceMap][asKey]
          throw new Error Controller::MULTITON_MSG
        Controller[cphInstanceMap][asKey] = @
        @[ipsMultitonKey] = asKey
        @[iphCommandMap] = {}
        @[iphClassNames] = {}
        @initializeController()
        return


    @initialize()
