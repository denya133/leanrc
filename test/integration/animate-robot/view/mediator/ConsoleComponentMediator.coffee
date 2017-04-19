

handleAnimateRobot = null

module.exports = (Module) ->
  class ConsoleComponentMediator extends Module::Mediator
    @inheritProtected()
    @Module: Module

    @const CONSOLE_MEDIATOR: 'consoleMediator'

    @public listNotificationInterests: Function,
      default: -> [
        Module::ROBOT_SPEAKING
      ]

    @public handleNotification: Function,
      default: (notification)->
        switch notification.getName()
          when Module::ROBOT_SPEAKING
            @getViewComponent()?.writeMessages notification.getBody()

    @public onRegister: Function,
      default: ->
        @setViewComponent Module::ConsoleComponent.getInstance()
        handleAnimateRobot = => @handleAnimateRobot()
        @getViewComponent()?.subscribeEvent Module::ConsoleComponent.ANIMATE_ROBOT_EVENT, handleAnimateRobot

    @public onRemove: Function,
      default: ->
        @getViewComponent()?.unsubscribeEvent Module::ConsoleComponent.ANIMATE_ROBOT_EVENT, handleAnimateRobot
        @setViewComponent null

    @public handleAnimateRobot: Function,
      default: ->
        @sendNotification Module::ANIMATE_ROBOT


  ConsoleComponentMediator.initialize()
