

module.exports = (Module)->
  {
    FuncG, MaybeG, InterfaceG
    FacadeInterface
    Interface
  } = Module::

  class DelayableInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual @static delay: FuncG [
      FacadeInterface
      MaybeG InterfaceG queue: MaybeG(String), delayUntil: MaybeG Number
    ]

    @virtual delay: FuncG [
      FacadeInterface
      MaybeG InterfaceG queue: MaybeG(String), delayUntil: MaybeG Number
    ]


    @initialize()
