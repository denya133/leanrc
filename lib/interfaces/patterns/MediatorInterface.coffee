

module.exports = (Module)->
  {
    AnyT, NilT
    FuncG
    NotificationInterface
    NotifierInterface
  } = Module::

  class MediatorInterface extends NotifierInterface
    @inheritProtected()
    @module Module

    @virtual getMediatorName: FuncG [], String
    @virtual getViewComponent: FuncG [], AnyT
    @virtual setViewComponent: FuncG AnyT, NilT
    @virtual listNotificationInterests: FuncG [], Array
    @virtual handleNotification: FuncG NotificationInterface, NilT
    @virtual onRegister: Function
    @virtual onRemove: Function


    @initialize()
