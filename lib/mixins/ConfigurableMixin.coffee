# миксин может подмешиваться в наследники классов Proxy, Command, Mediator

module.exports = (Module)->
  {
    CONFIGURATION
    CoreObject, Mixin
  } = Module::

  Module.defineMixin Mixin 'ConfigurableMixin', (BaseClass = CoreObject) ->
    class extends BaseClass
      @inheritProtected()

      @public configs: Object,
        get: ->
          @facade.retrieveProxy CONFIGURATION


      @initializeMixin()
