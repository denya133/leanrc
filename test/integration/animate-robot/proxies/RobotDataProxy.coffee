

module.exports = (Module) ->
  class RobotDataProxy extends Module.NS.Proxy
    @inheritProtected()
    @module Module

    @const ROBOT_PROXY: 'robotProxy'

    @public animate: Function,
      default: ->
        @setData yes
        if @getData()
          @sendNotification Module.NS.ROBOT_SPEAKING, 'I am awaken. Hello World'
        return

    @initialize()
