

handleAnimateRobot = null

module.exports = (Module) ->
  class ConsoleComponentMediator extends Module.NS.Mediator
    @inheritProtected()
    @module Module

    @const CONSOLE_MEDIATOR: 'consoleMediator'

    @public listNotificationInterests: Function,
      default: -> [
        Module.NS.ROBOT_SPEAKING
      ]

    @public handleNotification: Function,
      default: (notification)->
        switch notification.getName()
          when Module.NS.ROBOT_SPEAKING
            @getViewComponent()?.writeMessages notification.getBody()

    @public onRegister: Function,
      default: ->
        @setViewComponent Module.NS.ConsoleComponent.getInstance()
        handleAnimateRobot = => @handleAnimateRobot()
        @getViewComponent()?.subscribeEvent Module.NS.ConsoleComponent.ANIMATE_ROBOT_EVENT, handleAnimateRobot

    @public onRemove: Function,
      default: ->
        @getViewComponent()?.unsubscribeEvent Module.NS.ConsoleComponent.ANIMATE_ROBOT_EVENT, handleAnimateRobot
        @setViewComponent null

    @public handleAnimateRobot: Function,
      default: ->
        @sendNotification Module.NS.ANIMATE_ROBOT


  ConsoleComponentMediator.initialize()
