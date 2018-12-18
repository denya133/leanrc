

module.exports = (Module)->
  {
    AnyT
    FuncG, MaybeG
    Interface
  } = Module::

  class NotifierInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual sendNotification: FuncG [String, MaybeG(AnyT), MaybeG String]
    @virtual initializeNotifier: FuncG String


    @initialize()
