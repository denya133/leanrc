

module.exports = (Module)->
  {
    Renderer
  } = Module::

  Module.defineMixin 'BulkMethodsRendererMixin', (BaseClass = Renderer) ->
    class extends BaseClass
      @inheritProtected()

      @public bulkDelete: Function,
        default: (resource, action, aoData)->

      @public bulkDestroy: Function,
        default: (resource, action, aoData)->

      @public @async render: Function,
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
