

module.exports = (Module)->
  class DelayableMixinInterface extends Module::Interface
    @inheritProtected()

    @module Module

    @public @static @virtual delay: Function,
      args: [Module::FacadeInterface, [Object, Module::NILL]]
      return: Object


  DelayableMixinInterface.initialize()
