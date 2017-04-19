RC = require 'RC'
{NILL} = RC::


module.exports = (LeanRC)->
  class LeanRC::ModelInterface extends RC::Interface
    @inheritProtected()
    @Module: LeanRC

    @public @virtual registerProxy: Function,
      args: [LeanRC::ProxyInterface]
      return: NILL
    @public @virtual removeProxy: Function,
      args: [String]
      return: LeanRC::ProxyInterface
    @public @virtual retrieveProxy: Function,
      args: [String]
      return: LeanRC::ProxyInterface
    @public @virtual hasProxy: Function,
      args: [String]
      return: Boolean



  return LeanRC::ModelInterface.initialize()
