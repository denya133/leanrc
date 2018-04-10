

module.exports = (Module)->
  {
    Renderer
  } = Module::

  Module.defineMixin 'CountMethodsRendererMixin', (BaseClass = Renderer) ->
    class extends BaseClass
      @inheritProtected()

      @public count: Function,
        default: (resource, action, aoData)-> aoData

      @public length: Function,
        default: (resource, action, aoData)-> aoData

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
                'count', 'length'
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
