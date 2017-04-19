

handleSendRequest = null

module.exports = (Module) ->
  class ConsoleComponentMediator extends Module::Mediator
    @inheritProtected()
    @Module: Module

    @const CONSOLE_MEDIATOR: 'consoleMediator'

    @public listNotificationInterests: Function,
      default: -> [
        Module::RECEIVE_RESPONSE
      ]

    @public handleNotification: Function,
      default: (notification)->
        switch notification.getName()
          when Module::RECEIVE_RESPONSE
            @getViewComponent()?.writeMessages notification.getBody()

    @public onRegister: Function,
      default: ->
        @setViewComponent Module::ConsoleComponent.getInstance()
        handleSendRequest = => @handleSendRequest()
        @getViewComponent()?.subscribeEvent Module::ConsoleComponent::SEND_REQUEST_EVENT, handleSendRequest

    @public onRemove: Function,
      default: ->
        @getViewComponent()?.unsubscribeEvent Module::ConsoleComponent::SEND_REQUEST_EVENT, handleSendRequest
        @setViewComponent null

    @public handleSendRequest: Function,
      default: ->
        @sendNotification Module::SEND_REQUEST


  ConsoleComponentMediator.initialize()
