# миксин может подмешиваться в наследники класса Module


module.exports = (Module)->
  {
    Module: ModuleClass
    Utils: { _, inflect }
  } = Module::

  Module.defineMixin 'NamespaceModuleMixin', (BaseClass = ModuleClass) ->
    class extends BaseClass
      @inheritProtected()

      cpmHandler = @private @static handler: Function,
        default: (Class) ->
          get: (aoTarget, asName) ->
            unless Reflect.get aoTarget, asName
              vsPrefix = Class::ROOT
              vsName = inflect.underscore asName
              [ blackhole, vsTypeName ] = vsName.match(/^.*_(\w+)$/) ? []
              if vsTypeName
                if vsTypeName in [ 'gateway', 'collection', 'configuration', 'resque']
                  vsTypeName = 'proxy'
                unless vsTypeName in [ 'facade', 'router', 'application' ]
                  vsPrefix = "#{vsPrefix}/#{inflect.pluralize vsTypeName}"
              require("#{vsPrefix}/#{asName}") Class
            Reflect.get aoTarget, asName
      cpoNamespace = @private @static proto: Object

      @public @static NS: Object,
        get: ->
          @[cpoNamespace] ?= new Proxy @::, @[cpmHandler] @

      @public @static inheritProtected: Function,
        default: (args...) ->
          @super args...
          @[cpoNamespace] = undefined


      @initializeMixin()

###
Module.NS.CoreObject
{ CoreObject } = Module.NS
###
