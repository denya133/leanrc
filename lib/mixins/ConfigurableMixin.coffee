# миксин может подмешиваться в наследники классов Proxy, Command, Mediator

module.exports = (Module)->
  {
    CONFIGURATION

    CoreObject
  } = Module::

  Module.defineMixin CoreObject, (BaseClass) ->
    class ConfigurableMixin extends BaseClass
      @inheritProtected()

      @public configs: Object,
        get: ->
          @facade.retrieveProxy CONFIGURATION


    ConfigurableMixin.initializeMixin()
