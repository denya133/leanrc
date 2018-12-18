

module.exports = (Module)->
  {
    FuncG, DictG
    Mixin
    Module: ModuleClass
    Utils: { _, filesTreeSync }
  } = Module::

  Module.defineMixin Mixin 'TemplatableModuleMixin', (BaseClass = ModuleClass) ->
    class extends BaseClass
      @inheritProtected()

      @public @static templates: DictG(String, Function),
        get: -> @metaObject.getGroup 'templates', no

      @public @static defineTemplate: FuncG([String, Function], Function),
        default: (filename, fun)->
          vsRoot = @::ROOT ? '.'
          vsTemplatesDir = "#{vsRoot}/templates/"
          templateName = filename
            .replace vsTemplatesDir, ''
            .replace /\.js|\.coffee/, ''
          @metaObject.addMetaData 'templates', templateName, fun
          return fun

      @public @static resolveTemplate: FuncG([], Function),
        default: (args...)->
          vsRoot = @::ROOT ? '.'
          vsTemplatesDir = "#{vsRoot}/templates/"
          path = require 'path'
          templateName = path.resolve args...
            .replace vsTemplatesDir, ''
            .replace /\.js|\.coffee/, ''
          return @templates[templateName]

      @public @static loadTemplates: Function,
        default: ->
          vsRoot = @::ROOT ? '.'
          vsTemplatesDir = "#{vsRoot}/templates"
          files = filesTreeSync vsTemplatesDir, filesOnly: yes
          (files ? []).forEach (i)=>
            templateName = i.replace /\.js|\.coffee/, ''
            vsTemplatePath = "#{vsTemplatesDir}/#{templateName}"
            require(vsTemplatePath) @Module
          return


      @initializeMixin()
