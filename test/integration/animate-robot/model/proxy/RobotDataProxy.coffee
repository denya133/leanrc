LeanRC = require.main.require 'lib'

module.exports = (TestApp) ->
  class TestApp::RobotDataProxy extends LeanRC::Proxy
    @inheritProtected()
    @Module: TestApp

    @public @static ROBOT_PROXY: String,
      default: 'robotProxy'

    @public animate: Function,
      default: ->
        @setData yes
        if @getData()
          @sendNotification TestApp::AppConstants.ROBOT_SPEAKING, 'I am awaken. Hello World'

  TestApp::RobotDataProxy.initialize()
