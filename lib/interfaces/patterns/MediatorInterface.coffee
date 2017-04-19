

module.exports = (Module)->
  {ANY, NILL} = Module::

  class MediatorInterface extends Module::Interface
    @inheritProtected()
    @include Module::NotifierInterface

    @Module: Module

    @public @virtual getMediatorName: Function,
      args: []
      return: String
    @public @virtual getViewComponent: Function,
      args: []
      return: ANY
    @public @virtual setViewComponent: Function,
      args: [ANY]
      return: NILL
    @public @virtual listNotificationInterests: Function,
      args: []
      return: Array
    @public @virtual handleNotification: Function,
      args: [Module::NotificationInterface]
      return: NILL
    @public @virtual onRegister: Function,
      args: []
      return: NILL
    @public @virtual onRemove: Function,
      args: []
      return: NILL


  MediatorInterface.initialize()
