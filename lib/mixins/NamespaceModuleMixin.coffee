# миксин может подмешиваться в наследники класса Module


module.exports = (Module)->
  {
    PointerT
    MaybeG
    Mixin
    Module: ModuleClass
    Utils: { _, inflect, filesTreeSync }
  } = Module::

  Module.defineMixin Mixin 'NamespaceModuleMixin', (BaseClass = ModuleClass) ->
    class extends BaseClass
      @inheritProtected()

      cphPathMap = PointerT @private @static pathMap: MaybeG Object

      cpmHandler = PointerT @private @static handler: Function,
        default: (Class) ->
          get: (aoTarget, asName) ->
            unless Reflect.get aoTarget, asName
              vsPath = Class[cphPathMap][asName]
              if vsPath
                require(vsPath) Class
            Reflect.get aoTarget, asName
      cpoNamespace = PointerT @private @static proto: MaybeG Object

      @public @static NS: Object,
        get: ->
          vsRoot = @::ROOT
          @[cphPathMap] ?= filesTreeSync vsRoot, filesOnly: yes
            .reduce (vhResult, vsItem) ->
              if /\.(js|coffee)$/.test vsItem
                [ blackhole, vsName ] = vsItem.match(/(\w+)\.(js|coffee)$/) ? []
                if vsItem and vsName
                  vhResult[vsName] = "#{vsRoot}/#{vsItem}"
              vhResult
            , {}
          @[cpoNamespace] ?= new Proxy @::, @[cpmHandler] @

      @public @static inheritProtected: Function,
        default: (args...) ->
          @super args...
          @[cphPathMap] = undefined
          @[cpoNamespace] = undefined
          return


      @initializeMixin()

###
Module.NS.CoreObject
{ CoreObject } = Module.NS
###
