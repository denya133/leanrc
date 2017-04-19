RC = require 'RC'
{ANY, NILL} = RC::


module.exports = (LeanRC)->
  class LeanRC::NotifierInterface extends RC::Interface
    @inheritProtected()
    @Module: LeanRC

    @public @virtual sendNotification: Function,
      args: [String, ANY, String]
      return: NILL
    @public @virtual initializeNotifier: Function,
      args: [String]
      return: NILL


  return LeanRC::NotifierInterface.initialize()
