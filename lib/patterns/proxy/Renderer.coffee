_ = require 'lodash'

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

# Возможно стоит обдумать такую идею: валидировать выходящей joi схемой (которая нужна для свайгера) выходящий результат после рендера (но это применимо только для json)

module.exports = (Module)->
  class Renderer extends Module::Proxy
    @inheritProtected()
    @implements Module::RendererInterface
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
        "#{@Module::ROOT}/templates"

    # may be redefine at inheritance
    @public @async render: Function,
      default: (aoData, {path, resource, action} = {})->
        vhData = if _.isArray aoData
          Module::Utils.extend [], aoData
        else
          Module::Utils.extend {}, aoData
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
