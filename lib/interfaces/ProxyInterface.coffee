RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::ProxyInterface extends RC::Interface
    @include LeanRC::NotifierInterface

    @public @virtual getProxyName: Function,
      args: []
      return: String
    @public @virtual setData: Function,
      args: [RC::Constants.ANY]
      return: RC::Constants.NILL
    @public @virtual getData: Function,
      args: []
      return: RC::Constants.ANY
    @public @virtual onRegister: Function,
      args: []
      return: RC::Constants.NILL
    @public @virtual onRemove: Function,
      args: []
      return: RC::Constants.NILL


  return LeanRC::ProxyInterface.initialize()
