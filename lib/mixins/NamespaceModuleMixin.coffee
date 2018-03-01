# миксин может подмешиваться в наследники класса Module


module.exports = (Module)->
  {
    Module: ModuleClass
    Utils: { _, inflect }
  } = Module::

  Module.defineMixin 'NamespaceModuleMixin', (BaseClass = ModuleClass) ->
    class extends BaseClass
      @inheritProtected()

      cphPrefixMap = @private @static prefixMap: Object,
        default:
          proxy: [
            'gateway'
            'collection'
            'configuration'
            'resque'
            'renderer'
          ]
          mediator: [
            'switch'
            'executor'
          ]
          root: [
            'facade'
            'router'
            'application'
          ]

      cpmHandler = @private @static handler: Function,
        default: (Class) ->
          get: (aoTarget, asName) ->
            unless Reflect.get aoTarget, asName
              vsPrefix = Class::ROOT
              vsName = inflect.underscore asName
              [ blackhole, vsTypeName ] = vsName.match(/^.*_(\w+)$/) ? []
              if vsTypeName is 'interface'
                return
              if vsTypeName
                if vsTypeName in Class[cphPrefixMap].proxy
                  vsTypeName = 'proxy'
                if vsTypeName in Class[cphPrefixMap].mediator
                  vsTypeName = 'mediator'
                unless vsTypeName in Class[cphPrefixMap].root
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
