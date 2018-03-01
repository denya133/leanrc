# миксин может подмешиваться в наследники класса Module


module.exports = (Module)->
  {
    Module: ModuleClass
    Utils: { _, inflect, filesTreeSync }
  } = Module::

  Module.defineMixin 'NamespaceModuleMixin', (BaseClass = ModuleClass) ->
    class extends BaseClass
      @inheritProtected()

      cphPathMap = @private @static pathMap: Object

      cpmHandler = @private @static handler: Function,
        default: (Class) ->
          get: (aoTarget, asName) ->
            unless Reflect.get aoTarget, asName
              vsPath = Class[cphPathMap][asName]
              if vsPath
                require(vsPath) Class
            Reflect.get aoTarget, asName
      cpoNamespace = @private @static proto: Object

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


      @initializeMixin()

###
Module.NS.CoreObject
{ CoreObject } = Module.NS
###
