

module.exports = (Module)->
  {
    Renderer
  } = Module::

  Module.defineMixin 'CrudRendererMixin', (BaseClass = Renderer) ->
    class CrudRendererMixin extends BaseClass
      @inheritProtected()

      @public create: Function,
        default: (resource, action, aoData, templatePath)->
          templateName = templatePath.replace new RegExp("/#{action}$"), '/itemDecorator'
          itemDecorator = @Module.templates[templateName]
          itemDecorator ?= CrudRendererMixin::itemDecorator
          return "#{@itemEntityName}": itemDecorator.call @, aoData

      @public delete: Function,
        default: (resource, action, aoData)->

      @public detail: Function,
        default: (resource, action, aoData, templatePath)->
          templateName = templatePath.replace new RegExp("/#{action}$"), '/itemDecorator'
          itemDecorator = @Module.templates[templateName]
          itemDecorator ?= CrudRendererMixin::itemDecorator
          return "#{@itemEntityName}": itemDecorator.call @, aoData

      @public itemDecorator: Function,
        default: (aoData)->
          if aoData?
            result = JSON.parse JSON.stringify aoData
            result.createdAt = aoData.createdAt?.toISOString()
            result.updatedAt = aoData.updatedAt?.toISOString()
            result.deletedAt = aoData.deletedAt?.toISOString()
          else
            result = null
          result

      @public list: Function,
        default: (resource, action, aoData, templatePath)->
          templateName = templatePath.replace new RegExp("/#{action}$"), '/itemDecorator'
          itemDecorator = @Module.templates[templateName]
          itemDecorator ?= CrudRendererMixin::itemDecorator
          return {
            meta: aoData.meta
            "#{@listEntityName}": aoData.items.map itemDecorator.bind @
          }

      @public query: Function,
        default: (resource, action, aoData)-> aoData

      @public update: Function,
        default: (resource, action, aoData, templatePath)->
          templateName = templatePath.replace new RegExp("/#{action}$"), '/itemDecorator'
          itemDecorator = @Module.templates[templateName]
          itemDecorator ?= CrudRendererMixin::itemDecorator
          return "#{@itemEntityName}": itemDecorator.call @, aoData

      @public @async render: Function,
        default: (ctx, aoData, resource, {path, resource:resourceName, action, template:templatePath}={})->
          if path? and resourceName? and action?
            {templates} = @Module
            return yield Module::Promise.resolve(
              if templates?[templatePath]?
                templates?[templatePath]?.call(
                  resource, resourceName, action, aoData
                )
              else if action in [
                'create', 'delete', 'detail', 'list', 'update'
              ]
                @[action].call(
                  resource, resourceName, action, aoData, templatePath
                )
              else
                aoData
            )
          else
            yield return aoData


      @initializeMixin()
