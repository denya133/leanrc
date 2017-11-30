path = require 'path'


module.exports = (Module)->
  {
    Module: ModuleClass
    Utils: { _, filesTreeSync }
  } = Module::

  Module.defineMixin ModuleClass, (BaseClass) ->
    class TemplatableModuleMixin extends BaseClass
      @inheritProtected()

      @public @static templates: Object,
        get: -> @metaObject.getGroup 'templates'

      @public @static defineTemplate: Function,
        default: (filename, fun)->
          vsRoot = @::ROOT ? '.'
          vsTemplatesDir = "#{vsRoot}/templates/"
          templateName = filename
            .replace vsTemplatesDir, ''
            .replace /\.js|\.coffee/, ''
          @metaObject.addMetaData 'templates', templateName, fun
          return fun

      @public @static resolveTemplate: Function,
        default: (args...)->
          vsRoot = @::ROOT ? '.'
          vsTemplatesDir = "#{vsRoot}/templates/"
          templateName = path.resolve args...
            .replace vsTemplatesDir, ''
            .replace /\.js|\.coffee/, ''
          return @templates[templateName]

      @public @static loadTemplates: Function,
        default: ()->
          vsRoot = @::ROOT ? '.'
          vsTemplatesDir = "#{vsRoot}/templates"
          files = filesTreeSync vsTemplatesDir, filesOnly: yes
          _.orderBy _.compact (files ? []).forEach (i)=>
            templateName = i.replace /\.js|\.coffee/, ''
            vsTemplatePath = "#{vsTemplatesDir}/#{templateName}"
            require(vsTemplatePath) @Module
          return


    TemplatableModuleMixin.initializeMixin()
