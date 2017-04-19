RC = require 'RC'
{ANY, NILL} = RC::


module.exports = (LeanRC)->
  class LeanRC::ProxyInterface extends RC::Interface
    @inheritProtected()
    @include LeanRC::NotifierInterface

    @Module: LeanRC

    @public @virtual getProxyName: Function,
      args: []
      return: String
    @public @virtual setData: Function,
      args: [ANY]
      return: NILL
    @public @virtual getData: Function,
      args: []
      return: ANY
    @public @virtual onRegister: Function,
      args: []
      return: NILL
    @public @virtual onRemove: Function,
      args: []
      return: NILL


  return LeanRC::ProxyInterface.initialize()
