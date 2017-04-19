RC = require 'RC'
{ANY, NILL} = RC::


module.exports = (LeanRC)->
  class LeanRC::ObserverInterface extends RC::Interface
    @inheritProtected()
    @Module: LeanRC

    @public @virtual setNotifyMethod: Function,
      args: [Function]
      return: NILL
    @public @virtual setNotifyContext: Function,
      args: [ANY]
      return: NILL
    @public @virtual getNotifyMethod: Function,
      args: []
      return: Function
    @public @virtual getNotifyContext: Function,
      args: []
      return: ANY
    @public @virtual compareNotifyContext: Function,
      args: [ANY]
      return: Boolean
    @public @virtual notifyObserver: Function,
      args: [LeanRC::NotificationInterface]
      return: NILL



  return LeanRC::ObserverInterface.initialize()
