RC = require 'RC'


module.exports = (LeanRC)->
  class LeanRC::IterableMixinInterface extends RC::Interface
    @inheritProtected()

    @Module: LeanRC

    @public @async @virtual forEach: Function,
      args: [Function]
      return: RC::Constants.NILL
    @public @async @virtual filter: Function,
      args: [Function]
      return: Array
    @public @async @virtual map: Function,
      args: [Function]
      return: Array
    @public @async @virtual reduce: Function,
      args: [Function, RC::Constants.ANY]
      return: RC::Constants.ANY


  return LeanRC::IterableMixinInterface.initialize()
