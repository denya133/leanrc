

module.exports = (Module)->
  {
    AnyT, NilT
    FuncG, MaybeG
    Interface
  } = Module::

  class NotifierInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual sendNotification: FuncG [String, MaybeG(AnyT), MaybeG String], NilT
    @virtual initializeNotifier: FuncG String, NilT


    @initialize()
