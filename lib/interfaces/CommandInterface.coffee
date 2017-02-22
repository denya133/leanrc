RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::CommandInterface extends RC::Interface
    @include LeanRC::NotifierInterface
    
    @public @virtual execute: Function,
      args: [LeanRC::NotificationInterface]
      return: RC::Constants.NILL


  return LeanRC::CommandInterface.initialize()
