LeanRC = require.main.require 'lib'

module.exports = (TestApp) ->
  TestApp::AppConstants =
    STARTUP: 'startup'
    ANIMATE_ROBOT: 'animateRobot'
    ROBOT_SPEAKING: 'robotSpeaking'
