# миксин может подмешиваться в наследники классов Proxy, Command, Mediator

module.exports = (Module)->
  {
    CONFIGURATION

    CoreObject
  } = Module::

  Module.defineMixin 'ConfigurableMixin', (BaseClass = CoreObject) ->
    class extends BaseClass
      @inheritProtected()

      @public configs: Object,
        get: ->
          @facade.retrieveProxy CONFIGURATION


      @initializeMixin()
