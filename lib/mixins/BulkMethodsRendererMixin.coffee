

module.exports = (Module)->
  {
    AnyT
    FuncG, MaybeG, InterfaceG
    ContextInterface, ResourceInterface
    Renderer, Mixin
  } = Module::

  Module.defineMixin Mixin 'BulkMethodsRendererMixin', (BaseClass = Renderer) ->
    class extends BaseClass
      @inheritProtected()

      @public bulkDelete: FuncG([String, String, AnyT], MaybeG AnyT),
        default: (resource, action, aoData)->

      @public bulkDestroy: FuncG([String, String, AnyT], MaybeG AnyT),
        default: (resource, action, aoData)->

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
                'bulkDelete', 'bulkDestroy'
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
