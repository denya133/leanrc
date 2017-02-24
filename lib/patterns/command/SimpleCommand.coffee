RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::SimpleCommand extends LeanRC::Notifier
    @implements LeanRC::CommandInterface

    @public execute: Function,
      default: (notification)->



  return LeanRC::SimpleCommand.initialize()
