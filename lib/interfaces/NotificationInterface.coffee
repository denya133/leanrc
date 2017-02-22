RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::NotificationInterface extends RC::Interface
    @public getName: Function,
      args: []
      return: String
    @public setBody: Function,
      args: [Object]
      return RC::Constants.NILL
    @public getBody: Function,
      args: []
      return RC::Constants.ANY
    @public setType: Function,
      args: [String]
      return RC::Constants.NILL
    @public getType: Function,
      args: []
      return String
    @public toString: Function,
      args: []
      return String


  return LeanRC::NotificationInterface.initialize()
