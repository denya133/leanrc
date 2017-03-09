LeanRC = require.main.require 'lib'

handleSendRequest = null

module.exports = (RequestApp) ->
  class RequestApp::ConsoleComponentMediator extends LeanRC::Mediator
    @inheritProtected()
    @Module: RequestApp

    @public @static CONSOLE_MEDIATOR: String,
      default: 'consoleMediator'

    @public listNotificationInterests: Function,
      default: -> [
        RequestApp::AppConstants.RECEIVE_RESPONSE
      ]

    @public handleNotification: Function,
      default: (notification)->
        switch notification.getName()
          when RequestApp::AppConstants.RECEIVE_RESPONSE
            @getViewComponent()?.writeMessages notification.getBody()

    @public onRegister: Function,
      default: ->
        @setViewComponent RequestApp::ConsoleComponent.getInstance()
        handleSendRequest = => @handleSendRequest()
        @getViewComponent()?.subscribeEvent RequestApp::ConsoleComponent.SEND_REQUEST_EVENT, handleSendRequest

    @public onRemove: Function,
      default: ->
        @getViewComponent()?.unsubscribeEvent RequestApp::ConsoleComponent.SEND_REQUEST_EVENT, handleSendRequest
        @setViewComponent null

    @public handleSendRequest: Function,
      default: ->
        @sendNotification RequestApp::AppConstants.SEND_REQUEST


  RequestApp::ConsoleComponentMediator.initialize()
