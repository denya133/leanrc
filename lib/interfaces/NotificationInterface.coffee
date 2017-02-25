RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::NotificationInterface extends RC::Interface
    @inheritProtected()
    @Module: LeanRC

    @public @virtual getName: Function,
      args: []
      return: String
    @public @virtual setBody: Function,
      args: [Object]
      return: RC::Constants.NILL
    @public @virtual getBody: Function,
      args: []
      return: RC::Constants.ANY
    @public @virtual setType: Function,
      args: [String]
      return: RC::Constants.NILL
    @public @virtual getType: Function,
      args: []
      return: String
    @public @virtual toString: Function,
      args: []
      return: String


  return LeanRC::NotificationInterface.initialize()
