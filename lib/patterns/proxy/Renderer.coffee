_ = require 'lodash'

###
пример темплейта
```coffee
_         = require 'lodash'
inflect   = do require 'i'

# это специально не класс, а функция чтобы съэкономить процессорные ресурсы
module.exports = (resource, action, aoData)->
  resource = resource.replace(/[/]/g, '_').replace /[_]$/g, ''
  meta: aoData.meta
  "#{inflect.pluralize inflect.underscore resource}": aoData.items.map (i)->
    _.omit i, '_key', '_type', '_owner'

```
но также могут быть созданы обобщенные шаблоны, с каким-то кодом представления одного или нескольких итемов, чтобы в темплейтах рекваить (с них доп-параметры можно передавать аргументами или через карирование)
###

# Возможно стоит обдумать такую идею: валидировать выходящей joi схемой (которая нужна для свайгера) выходящий результат после рендера (но это применимо только для json)

module.exports = (Module)->
  class Renderer extends Module::Proxy
    @inheritProtected()
    # @implements Module::RendererInterface
    @include Module::ConfigurableMixin
    @module Module

    ipoTemplates = @private templates: Module::PromiseInterface
    @public templates: Module::PromiseInterface,
      get: ->
        {co, filesTree} = Module::Utils
        @[ipoTemplates] ?= co =>
          files = yield filesTree @templatesDir, filesOnly: yes
          (files ? []).map (i)=>
            templateName = i.replace /\.js|\.coffee/, ''
            vsTemplatePath = "#{@templatesDir}/#{templateName}"
            [templateName, require vsTemplatePath]
          .reduce (acc, [key, value])->
            acc[key] = value
            acc
          , {}
        @[ipoTemplates]

    @public templatesDir: String,
      get: ->
        "#{@configs.ROOT}/../lib/templates"

    # may be redefine at inheritance
    @public @async render: Function,
      default: (ctx, aoData, resource, {path, resource:resourceName, action}={})->
        if path? and resourceName? and action?
          templatePath = resourceName + action
          templates = yield @templates
          renderedResult = if templates[templatePath]?
            yield Module::Promise.resolve templates[templatePath].call resource, resourceName, action, aoData
          else
            null
          yield return renderedResult ? aoData ? null
        else
          yield return aoData


  Renderer.initialize()
