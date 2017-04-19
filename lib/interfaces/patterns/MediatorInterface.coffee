RC = require 'RC'
{ANY, NILL} = RC::


module.exports = (LeanRC)->
  class LeanRC::MediatorInterface extends RC::Interface
    @inheritProtected()
    @include LeanRC::NotifierInterface

    @Module: LeanRC

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
      args: [LeanRC::NotificationInterface]
      return: NILL
    @public @virtual onRegister: Function,
      args: []
      return: NILL
    @public @virtual onRemove: Function,
      args: []
      return: NILL


  return LeanRC::MediatorInterface.initialize()
