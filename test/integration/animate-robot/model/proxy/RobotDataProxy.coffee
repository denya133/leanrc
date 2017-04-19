

module.exports = (Module) ->
  class RobotDataProxy extends Module::Proxy
    @inheritProtected()
    @Module: Module

    @const ROBOT_PROXY: 'robotProxy'

    @public animate: Function,
      default: ->
        @setData yes
        if @getData()
          @sendNotification Module::ROBOT_SPEAKING, 'I am awaken. Hello World'

  RobotDataProxy.initialize()
