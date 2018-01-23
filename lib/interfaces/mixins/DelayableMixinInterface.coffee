

module.exports = (Module)->
  Module.defineInterface 'DelayableMixinInterface', (BaseClass) ->
    class extends BaseClass
      @inheritProtected()

      @public @static @virtual delay: Function,
        args: [Module::FacadeInterface, [Object, Module::NILL]]
        return: Object


      @initializeInterface()
