LeanRC = require.main.require 'lib'

handleAnimateRobot = null

module.exports = (TestApp) ->
  class TestApp::ConsoleComponentMediator extends LeanRC::Mediator
    @inheritProtected()
    @Module: TestApp

    @public @static CONSOLE_MEDIATOR: String,
      default: 'consoleMediator'

    @public listNotificationInterests: Function,
      default: -> [
        TestApp::AppConstants.ROBOT_SPEAKING
      ]

    @public handleNotification: Function,
      default: (notification)->
        switch notification.getName()
          when TestApp::AppConstants.ROBOT_SPEAKING
            @getViewComponent()?.writeMessages notification.getBody()

    @public onRegister: Function,
      default: ->
        @setViewComponent TestApp::ConsoleComponent.getInstance()
        handleAnimateRobot = => @handleAnimateRobot()
        @getViewComponent()?.subscribeEvent TestApp::ConsoleComponent.ANIMATE_ROBOT_EVENT, handleAnimateRobot

    @public onRemove: Function,
      default: ->
        @getViewComponent()?.unsubscribeEvent TestApp::ConsoleComponent.ANIMATE_ROBOT_EVENT, handleAnimateRobot
        @setViewComponent null

    @public handleAnimateRobot: Function,
      default: ->
        @sendNotification TestApp::AppConstants.ANIMATE_ROBOT


  TestApp::ConsoleComponentMediator.initialize()
