RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::MediatorInterface extends RC::Interface
    @include LeanRC::NotifierInterface

    @Module: LeanRC

    @public @virtual getMediatorName: Function,
      args: []
      return: String
    @public @virtual getViewComponent: Function,
      args: []
      return: RC::Constants.ANY
    @public @virtual setViewComponent: Function,
      args: [RC::Constants.ANY]
      return: RC::Constants.NILL
    @public @virtual listNotificationInterests: Function,
      args: []
      return: Array
    @public @virtual handleNotification: Function,
      args: [LeanRC::NotificationInterface]
      return: RC::Constants.NILL
    @public @virtual onRegister: Function,
      args: []
      return: RC::Constants.NILL
    @public @virtual onRemove: Function,
      args: []
      return: RC::Constants.NILL


  return LeanRC::MediatorInterface.initialize()
