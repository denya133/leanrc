

module.exports = (Module)->
  {
    AnyT, NilT
    FuncG, MaybeG, InterfaceG
    ContextInterface, ResourceInterface
    Renderer, Mixin
  } = Module::

  Module.defineMixin Mixin 'CrudRendererMixin', (BaseClass = Renderer) ->
    class CrudRendererMixin extends BaseClass
      @inheritProtected()

      @public create: FuncG([String, String, Object, MaybeG String], Object),
        default: (resource, action, aoData, templatePath)->
          templateName = templatePath.replace new RegExp("/#{action}$"), '/itemDecorator'
          itemDecorator = @Module.templates[templateName]
          itemDecorator ?= CrudRendererMixin::itemDecorator
          return "#{@itemEntityName}": itemDecorator.call @, aoData

      @public delete: FuncG([String, String, NilT, MaybeG String]),
        default: (resource, action, aoData)->

      @public destroy: FuncG([String, String, NilT, MaybeG String]),
        default: (resource, action, aoData)->

      @public detail: FuncG([String, String, Object, MaybeG String], Object),
        default: (resource, action, aoData, templatePath)->
          templateName = templatePath.replace new RegExp("/#{action}$"), '/itemDecorator'
          itemDecorator = @Module.templates[templateName]
          itemDecorator ?= CrudRendererMixin::itemDecorator
          return "#{@itemEntityName}": itemDecorator.call @, aoData

      @public itemDecorator: FuncG([MaybeG Object], MaybeG Object),
        default: (aoData)->
          if aoData?
            result = JSON.parse JSON.stringify aoData
            result.createdAt = aoData.createdAt?.toISOString()
            result.updatedAt = aoData.updatedAt?.toISOString()
            result.deletedAt = aoData.deletedAt?.toISOString()
          else
            result = null
          result

      @public list: FuncG([String, String, Object, MaybeG String], Object),
        default: (resource, action, aoData, templatePath)->
          templateName = templatePath.replace new RegExp("/#{action}$"), '/itemDecorator'
          itemDecorator = @Module.templates[templateName]
          itemDecorator ?= CrudRendererMixin::itemDecorator
          return {
            meta: aoData.meta
            "#{@listEntityName}": aoData.items.map itemDecorator.bind @
          }

      @public query: FuncG([String, String, MaybeG(AnyT), MaybeG String], MaybeG AnyT),
        default: (resource, action, aoData)-> aoData

      @public update: FuncG([String, String, Object, MaybeG String], Object),
        default: (resource, action, aoData, templatePath)->
          templateName = templatePath.replace new RegExp("/#{action}$"), '/itemDecorator'
          itemDecorator = @Module.templates[templateName]
          itemDecorator ?= CrudRendererMixin::itemDecorator
          return "#{@itemEntityName}": itemDecorator.call @, aoData

      @public @async render: FuncG([ContextInterface, AnyT, ResourceInterface, MaybeG InterfaceG {
        method: String
        path: String
        resource: String
        action: String
        tag: String
        template: String
        keyName: MaybeG String
        entityName: String
        recordName: MaybeG String
      }], MaybeG AnyT),
        default: (args...)->
          [ctx, aoData, resource, options = {}] = args
          {path, resource:resourceName, action, template:templatePath} = options
          if path? and resourceName? and action?
            {templates} = @Module
            return yield Module::Promise.resolve(
              if templates?[templatePath]?
                templates?[templatePath]?.call(
                  resource, resourceName, action, aoData
                )
              else if action in [
                'create', 'delete', 'destroy', 'detail', 'list', 'update'
              ]
                @[action].call(
                  resource, resourceName, action, aoData, templatePath
                )
              else
                yield @super args...
            )
          else
            yield return aoData


      @initializeMixin()
