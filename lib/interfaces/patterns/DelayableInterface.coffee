

module.exports = (Module)->
  {
    AsyncFunctionT
    FuncG, MaybeG, InterfaceG, DictG
    FacadeInterface
    Interface
  } = Module::

  class DelayableInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual @static delay: FuncG [
      FacadeInterface
      MaybeG InterfaceG queue: MaybeG(String), delayUntil: MaybeG Number
    ], DictG String, AsyncFunctionT

    @virtual delay: FuncG [
      FacadeInterface
      MaybeG InterfaceG queue: MaybeG(String), delayUntil: MaybeG Number
    ], DictG String, AsyncFunctionT


    @initialize()
