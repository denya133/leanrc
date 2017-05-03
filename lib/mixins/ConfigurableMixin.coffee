# миксин может подмешиваться в наследники классов Proxy, Command, Mediator

module.exports = (Module)->
  {
    CONFIGURATION
  } = Module::

  Module.defineMixin (BaseClass) ->
    class ConfigurableMixin extends BaseClass
      @inheritProtected()

      @public configs: Object,
        get: ->
          @facade.retriveProxy CONFIGURATION


    ConfigurableMixin.initializeMixin()
