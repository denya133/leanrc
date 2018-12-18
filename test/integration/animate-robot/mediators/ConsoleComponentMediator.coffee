

handleAnimateRobot = null

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
        Module.NS.ROBOT_SPEAKING
      ]

    @public handleNotification: FuncG(NotificationInterface, NilT),
      default: (notification)->
        switch notification.getName()
          when Module.NS.ROBOT_SPEAKING
            @getViewComponent()?.writeMessages notification.getBody()
        return

    @public onRegister: Function,
      default: ->
        @setViewComponent Module.NS.ConsoleComponent.getInstance()
        handleAnimateRobot = => @handleAnimateRobot()
        @getViewComponent()?.subscribeEvent Module.NS.ConsoleComponent.ANIMATE_ROBOT_EVENT, handleAnimateRobot
        return

    @public onRemove: Function,
      default: ->
        @getViewComponent()?.unsubscribeEvent Module.NS.ConsoleComponent.ANIMATE_ROBOT_EVENT, handleAnimateRobot
        # @setViewComponent null
        return

    @public handleAnimateRobot: Function,
      default: ->
        @sendNotification Module.NS.ANIMATE_ROBOT
        return


    @initialize()
