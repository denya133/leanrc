

handleSendRequest = null

module.exports = (Module) ->
  class ConsoleComponentMediator extends Module.NS.Mediator
    @inheritProtected()
    @module Module

    @const CONSOLE_MEDIATOR: 'consoleMediator'

    @public listNotificationInterests: Function,
      default: -> [
        Module.NS.RECEIVE_RESPONSE
      ]

    @public handleNotification: Function,
      default: (notification)->
        switch notification.getName()
          when Module.NS.RECEIVE_RESPONSE
            @getViewComponent()?.writeMessages notification.getBody()

    @public onRegister: Function,
      default: ->
        @setViewComponent Module.NS.ConsoleComponent.getInstance()
        handleSendRequest = => @handleSendRequest()
        @getViewComponent()?.subscribeEvent Module.NS.ConsoleComponent::SEND_REQUEST_EVENT, handleSendRequest

    @public onRemove: Function,
      default: ->
        @getViewComponent()?.unsubscribeEvent Module.NS.ConsoleComponent::SEND_REQUEST_EVENT, handleSendRequest
        @setViewComponent null

    @public handleSendRequest: Function,
      default: ->
        @sendNotification Module.NS.SEND_REQUEST


  ConsoleComponentMediator.initialize()
