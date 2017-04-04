RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::JunctionMediator extends LeanRC::Mediator
    @inheritProtected()

    @Module: LeanRC

    @public @static ACCEPT_INPUT_PIPE: String,
      default: 'acceptInputPipe'
    @public @static ACCEPT_OUTPUT_PIPE: String,
      default: 'acceptOutputPipe'
    @public @static REMOVE_PIPE: String,
      default: 'removePipe'

    ipoJunction = @protected junction: LeanRC::Junction,
      get: ->
        @getViewComponent()

    @public listNotificationInterests: Function,
      default: ->
        [
          LeanRC::JunctionMediator.ACCEPT_INPUT_PIPE
          LeanRC::JunctionMediator.ACCEPT_OUTPUT_PIPE
          LeanRC::JunctionMediator.REMOVE_PIPE
        ]

    @public handleNotification: Function,
      default: (aoNotification)->
        switch aoNotification.getName()
          when LeanRC::JunctionMediator.ACCEPT_INPUT_PIPE
            inputPipeName = aoNotification.getType()
            inputPipe = aoNotification.getBody()
            if @[ipoJunction].registerPipe inputPipeName, LeanRC::Junction.INPUT, inputPipe
              @[ipoJunction].addPipeListener inputPipeName, @, @handlePipeMessage
          when LeanRC::JunctionMediator.ACCEPT_OUTPUT_PIPE
            outputPipeName = aoNotification.getType()
            outputPipe = aoNotification.getBody()
            @[ipoJunction].registerPipe outputPipeName, LeanRC::Junction.OUTPUT, outputPipe
          when LeanRC::JunctionMediator.REMOVE_PIPE
            outputPipeName = aoNotification.getType()
            @[ipoJunction].removePipe outputPipeName
        return

    @public handlePipeMessage: Function,
      args: [LeanRC::PipeMessageInterface]
      return: RC::Constants.NILL
      default: (aoMessage)->
        @sendNotification aoMessage.getType(), aoMessage


  return LeanRC::JunctionMediator.initialize()
