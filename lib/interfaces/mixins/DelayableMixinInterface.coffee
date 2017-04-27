

module.exports = (Module)->
  Module.defineInterface (BaseClass) ->
    class DelayableMixinInterface extends BaseClass
      @inheritProtected()

      @public @static @virtual delay: Function,
        args: [Module::FacadeInterface, [Object, Module::NILL]]
        return: Object


    DelayableMixinInterface.initializeInterface()
