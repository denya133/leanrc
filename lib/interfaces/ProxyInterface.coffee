RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::ProxyInterface extends RC::Interface
    @include LeanRC::NotifierInterface

    @public getProxyName: Function,
      args: []
      return: String
    @public setData: Function,
      args: [RC::Constants.ANY]
      return: RC::Constants.NILL
    @public getData: Function,
      args: []
      return: RC::Constants.ANY
    @public onRegister: Function,
      args: []
      return: RC::Constants.NILL
    @public onRemove: Function,
      args: []
      return: RC::Constants.NILL


  return LeanRC::ProxyInterface.initialize()
