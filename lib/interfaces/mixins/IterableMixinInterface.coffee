RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::IterableMixinInterface extends RC::Interface
    @inheritProtected()

    @Module: LeanRC

    @public @virtual forEach: Function,
      args: [Function]
      return: RC::Constants.NILL
    @public @virtual filter: Function,
      args: [Function]
      return: Array
    @public @virtual map: Function,
      args: [Function]
      return: Array
    @public @virtual reduce: Function,
      args: [Function, RC::Constants.ANY]
      return: RC::Constants.ANY


  return LeanRC::IterableMixinInterface.initialize()
