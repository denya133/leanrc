RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::CommandInterface extends RC::Interface
    @inheritProtected()
    @include LeanRC::NotifierInterface

    @Module: LeanRC

    @public @virtual execute: Function,
      args: [LeanRC::NotificationInterface]
      return: RC::Constants.NILL


  return LeanRC::CommandInterface.initialize()
