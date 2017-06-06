

module.exports = (Module)->
  class JunctionMediator extends Module::Mediator
    @inheritProtected()

    @module Module

    @public @static ACCEPT_INPUT_PIPE: String,
      default: 'acceptInputPipe'
    @public @static ACCEPT_OUTPUT_PIPE: String,
      default: 'acceptOutputPipe'
    @public @static REMOVE_PIPE: String,
      default: 'removePipe'

    ipoJunction = @protected junction: Module::Junction,
      get: ->
        @getViewComponent()

    @public listNotificationInterests: Function,
      default: ->
        [
          Module::JunctionMediator.ACCEPT_INPUT_PIPE
          Module::JunctionMediator.ACCEPT_OUTPUT_PIPE
          Module::JunctionMediator.REMOVE_PIPE
        ]

    @public handleNotification: Function,
      default: (aoNotification)->
        switch aoNotification.getName()
          when Module::JunctionMediator.ACCEPT_INPUT_PIPE
            inputPipeName = aoNotification.getType()
            inputPipe = aoNotification.getBody()
            if @[ipoJunction].registerPipe inputPipeName, Module::Junction.INPUT, inputPipe
              @[ipoJunction].addPipeListener inputPipeName, @, @handlePipeMessage
          when Module::JunctionMediator.ACCEPT_OUTPUT_PIPE
            outputPipeName = aoNotification.getType()
            outputPipe = aoNotification.getBody()
            @[ipoJunction].registerPipe outputPipeName, Module::Junction.OUTPUT, outputPipe
          when Module::JunctionMediator.REMOVE_PIPE
            outputPipeName = aoNotification.getType()
            @[ipoJunction].removePipe outputPipeName
        return

    @public handlePipeMessage: Function,
      args: [Module::PipeMessageInterface]
      return: Module::NILL
      default: (aoMessage)->
        @sendNotification aoMessage.getType(), aoMessage

    @public @static @async restoreObject: Function,
      default: ->
        throw new Error "restoreObject method not supported for #{@name}"
        yield return

    @public @static @async replicateObject: Function,
      default: ->
        throw new Error "replicateObject method not supported for #{@name}"
        yield return


  JunctionMediator.initialize()
