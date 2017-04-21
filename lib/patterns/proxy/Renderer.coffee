

###
пример темплейта
```coffee
_         = require 'lodash'
inflect   = do require 'inflect'

# это специально не класс, а функция чтобы съэкономить процессорные ресурсы
module.exports = (resource, aoData)->
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

    @public templates: Object

    @public templatesDir: String,
      get: ->
        "#{@Module::ROOT}/templates"

    @public findTemplates: Function,
      default: ->
        {filesTree} = Module::Utils
        @templates = filesTree(@templatesDir).map (i)=>
          templateName = i.replace '.js', ''
          vsTemplatePath = "#{@templatesDir}/#{templateName}"
          [templateName, require vsTemplatePath]
        .reduce ([key, value], prev)->
          prev[key] = value
        , {}

    @public onRegister: Function,
      default: (args...)->
        @super args...
        @findTemplates()
        return

    # may be redefine at inheritance
    @public render: Function,
      default: (aoData, {path, resource, action})->
        vhData = Module::Utils.extend {}, aoData
        # открытый вопрос - как определить какой темплейт рендерить
        JSON.stringify @templates[path]?(resource, vhData) ? vhData ? null



  Renderer.initialize()
