

###
пример темплейта
```coffee
_         = require 'lodash'
inflect   = do require 'inflect'

# это специально не класс, а функция чтобы съэкономить процессорные ресурсы
module.exports = (resource, action, aoData)->
  "#{inflect.pluralaze inflect.undescore resource}": aoData.map (i)->
    _.omit i, '_key', '_type', '_owner'
```
но также могут быть созданы обобщенные шаблоны, с каким-то кодом представления одного или нескольких итемов, чтобы в темплейтах рекваить (с них доп-параметры можно передавать аргументами или через карирование)
###


module.exports = (Module)->
  class Renderer extends Module::Proxy
    @inheritProtected()
    @implements Module::RendererInterface

    @module Module

    ipoTemplates = @private templates: Module::PromiseInterface
    @public templates: Module::PromiseInterface,
      get: ->
        {co, filesTree} = Module::Utils
        @[ipoTemplates] ?= co =>
          files = yield filesTree @templatesDir
          (files ? []).map (i)=>
            templateName = i.replace '.js', ''
            vsTemplatePath = "#{@templatesDir}/#{templateName}"
            [templateName, require vsTemplatePath]
          .reduce ([key, value], prev)->
            prev[key] = value
            prev
          , {}
        @[ipoTemplates]

    @public templatesDir: String,
      get: ->
        "#{@Module::ROOT}/templates"

    # may be redefine at inheritance
    @public @async render: Function,
      default: (aoData, {path, resource, action} = {})->
        vhData = Module::Utils.extend {}, aoData
        if path? and resource? and action?
          # открытый вопрос - как определить какой темплейт рендерить
          # вопрос в том еще - как должен выглядить путь до темплейта
          # и как он должен соотноситься с path
          templates = yield @templates
          renderedResult = templates[path]? resource, action, vhData
          res = JSON.stringify renderedResult ? vhData ? null
          yield return res
        else
          yield return JSON.stringify vhData


  Renderer.initialize()
