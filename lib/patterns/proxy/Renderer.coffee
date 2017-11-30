

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
  {
    APPLICATION_MEDIATOR
    # ConfigurableMixin
  } = Module::

  class Renderer extends Module::Proxy
    @inheritProtected()
    # @implements Module::RendererInterface
    # @include ConfigurableMixin
    @module Module

    # may be redefine at inheritance
    @public @async render: Function,
      default: (ctx, aoData, resource, {path, resource:resourceName, action, template:templatePath}={})->
        if path? and resourceName? and action?
          service = @facade.retrieveMediator APPLICATION_MEDIATOR
            ?.getViewComponent()
          {templates} = service.Module
          return yield Module::Promise.resolve(
            templates?[templatePath]?.call(
              resource, resourceName, action, aoData
            ) ? aoData
          )
        else
          yield return aoData


  Renderer.initialize()
