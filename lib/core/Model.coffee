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
    AnyT, PointerT
    SubsetG, DictG, FuncG, StructG, MaybeG
    ProxyInterface
    ModelInterface
    CoreObject, Facade
    Utils: { _ }
  } = Module::

  class Model extends CoreObject
    @inheritProtected()
    @implements ModelInterface
    @module Module

    @const MULTITON_MSG: "Model instance for this multiton key already constructed!"

    iphProxyMap     = PointerT @private proxyMap: DictG String, MaybeG ProxyInterface
    iphMetaProxyMap = PointerT @private metaProxyMap: DictG String, MaybeG StructG {
      className: MaybeG String
      data: MaybeG AnyT
    }
    ipsMultitonKey  = PointerT @protected multitonKey: MaybeG String
    cphInstanceMap  = PointerT @private @static _instanceMap: DictG(String, MaybeG ModelInterface),
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

    @public @static getInstance: FuncG(String, ModelInterface),
      default: (asKey)->
        unless Model[cphInstanceMap][asKey]?
          Model[cphInstanceMap][asKey] = Model.new asKey
        Model[cphInstanceMap][asKey]

    @public @static removeModel: FuncG(String),
      default: (asKey)->
        if (voModel = Model[cphInstanceMap][asKey])?
          for asProxyName in Reflect.ownKeys voModel[iphProxyMap]
            voModel.removeProxy asProxyName
          Model[cphInstanceMap][asKey] = undefined
          delete Model[cphInstanceMap][asKey]
        return

    @public registerProxy: FuncG(ProxyInterface),
      default: (aoProxy)->
        aoProxy.initializeNotifier @[ipsMultitonKey]
        @[iphProxyMap][aoProxy.getProxyName()] = aoProxy
        aoProxy.onRegister()
        return

    @public addProxy: FuncG(ProxyInterface),
      default: (args...)-> @registerProxy args...

    @public removeProxy: FuncG(String, MaybeG ProxyInterface),
      default: (asProxyName)->
        voProxy = @[iphProxyMap][asProxyName]
        if voProxy
          @[iphProxyMap][asProxyName] = undefined
          @[iphMetaProxyMap][asProxyName] = undefined
          delete @[iphProxyMap][asProxyName]
          delete @[iphMetaProxyMap][asProxyName]
          voProxy.onRemove()
        return voProxy

    @public retrieveProxy: FuncG(String, MaybeG ProxyInterface),
      default: (asProxyName)->
        unless @[iphProxyMap][asProxyName]?
          { className, data = {} } = @[iphMetaProxyMap][asProxyName] ? {}
          unless _.isEmpty className
            Class = (@ApplicationModule.NS ? @ApplicationModule::)[className]
            @registerProxy Class.new asProxyName, data
        @[iphProxyMap][asProxyName] ? null

    @public getProxy: FuncG(String, MaybeG ProxyInterface),
      default: (args...)-> @retrieveProxy args...

    @public hasProxy: FuncG(String, Boolean),
      default: (asProxyName)->
        @[iphProxyMap][asProxyName]? or @[iphMetaProxyMap][asProxyName]?

    @public lazyRegisterProxy: FuncG([String, MaybeG(String), MaybeG AnyT]),
      default: (asProxyName, asProxyClassName, ahData)->
        @[iphMetaProxyMap][asProxyName] =
          className: asProxyClassName
          data: ahData
        return

    @public initializeModel: Function,
      default: ->

    @public init: FuncG(String),
      default: (asKey)->
        @super arguments...
        if Model[cphInstanceMap][asKey]
          throw new Error Model::MULTITON_MSG
        Model[cphInstanceMap][asKey] = @
        @[ipsMultitonKey] = asKey
        @[iphProxyMap] = {}
        @[iphMetaProxyMap] = {}

        @initializeModel()
        return


    @initialize()
