

module.exports = (Module)->
  {
    AnyT
    FuncG, MaybeG
    NotificationInterface
    NotifierInterface
  } = Module::

  class MediatorInterface extends NotifierInterface
    @inheritProtected()
    @module Module

    @virtual getMediatorName: FuncG [], String
    @virtual getViewComponent: FuncG [], MaybeG AnyT
    @virtual setViewComponent: FuncG AnyT
    @virtual listNotificationInterests: FuncG [], Array
    @virtual handleNotification: FuncG NotificationInterface
    @virtual onRegister: Function
    @virtual onRemove: Function


    @initialize()
