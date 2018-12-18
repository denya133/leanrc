LeanRC = require.main.require 'lib'


class TestApp extends LeanRC
  @inheritProtected()
  @include LeanRC::NamespaceModuleMixin

  @root __dirname

  @const ANIMATE_ROBOT: 'animateRobot'
  @const ROBOT_SPEAKING: 'robotSpeaking'


module.exports = TestApp.initialize()
