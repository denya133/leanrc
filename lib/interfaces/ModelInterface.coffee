RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::ModelInterface extends RC::Interface
    @public registerProxy: Function,
      args: [LeanRC::ProxyInterface]
      return: RC::Constants.NILL
    @public removeProxy: Function,
      args: [String]
      return: LeanRC::ProxyInterface
    @public retrieveProxy: Function,
      args: [String]
      return: LeanRC::ProxyInterface
    @public hasProxy: Function,
      args: [String]
      return: Boolean



  return LeanRC::ModelInterface.initialize()
