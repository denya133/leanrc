RC = require 'RC'
{ANY, NILL} = RC::


module.exports = (LeanRC)->
  class LeanRC::ViewInterface extends RC::Interface
    @inheritProtected()
    @Module: LeanRC

    @public @virtual registerObserver: Function,
      args: [String, LeanRC::ObserverInterface]
      return: NILL
    @public @virtual removeObserver: Function,
      args: [String, ANY]
      return: NILL
    @public @virtual notifyObservers: Function,
      args: [LeanRC::NotificationInterface]
      return: NILL
    @public @virtual registerMediator: Function,
      args: [LeanRC::MediatorInterface]
      return: NILL
    @public @virtual retrieveMediator: Function,
      args: [String]
      return: LeanRC::MediatorInterface
    @public @virtual removeMediator: Function,
      args: [String]
      return: LeanRC::MediatorInterface
    @public @virtual hasMediator: Function,
      args: [String]
      return: Boolean


  return LeanRC::ViewInterface.initialize()
