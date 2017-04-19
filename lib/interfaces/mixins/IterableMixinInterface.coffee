RC = require 'RC'
{ANY, NILL} = RC::


module.exports = (LeanRC)->
  class LeanRC::IterableMixinInterface extends RC::Interface
    @inheritProtected()

    @Module: LeanRC

    @public @async @virtual forEach: Function,
      args: [Function]
      return: NILL
    @public @async @virtual filter: Function,
      args: [Function]
      return: Array
    @public @async @virtual map: Function,
      args: [Function]
      return: Array
    @public @async @virtual reduce: Function,
      args: [Function, ANY]
      return: ANY


  return LeanRC::IterableMixinInterface.initialize()
