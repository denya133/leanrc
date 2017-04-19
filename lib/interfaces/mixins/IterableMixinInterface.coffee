

module.exports = (Module)->
  {ANY, NILL} = Module::

  class IterableMixinInterface extends Module::Interface
    @inheritProtected()

    @Module: Module

    @public @async @virtual forEach: Function,
      args: [Function]
      return: NILL
    @public @async @virtual filter: Function,
      args: [Function]
      return: Array
    @public @async @virtual map: Function,
      args: [Function]
      return: Array
    @public @async @virtual reduce: Function,
      args: [Function, ANY]
      return: ANY


  IterableMixinInterface.initialize()
