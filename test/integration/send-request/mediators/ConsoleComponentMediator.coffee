

handleSendRequest = null

module.exports = (Module) ->
  {
    NilT
    FuncG
    NotificationInterface
    Mediator
  } = Module.NS

  class ConsoleComponentMediator extends Mediator
    @inheritProtected()
    @module Module

    @const CONSOLE_MEDIATOR: 'consoleMediator'

    @public listNotificationInterests: FuncG([], Array),
      default: -> [
        Module.NS.RECEIVE_RESPONSE
      ]

    @public handleNotification: FuncG(NotificationInterface, NilT),
      default: (notification)->
        switch notification.getName()
          when Module.NS.RECEIVE_RESPONSE
            @getViewComponent()?.writeMessages notification.getBody()
        return

    @public onRegister: Function,
      default: ->
        @setViewComponent Module.NS.ConsoleComponent.getInstance()
        handleSendRequest = => @handleSendRequest()
        @getViewComponent()?.subscribeEvent Module.NS.ConsoleComponent::SEND_REQUEST_EVENT, handleSendRequest
        return

    @public onRemove: Function,
      default: ->
        @getViewComponent()?.unsubscribeEvent Module.NS.ConsoleComponent::SEND_REQUEST_EVENT, handleSendRequest
        # @setViewComponent null
        return

    @public handleSendRequest: Function,
      default: ->
        @sendNotification Module.NS.SEND_REQUEST
        return


    @initialize()
