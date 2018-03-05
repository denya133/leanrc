LeanRC = require.main.require 'lib'


class TestApp extends LeanRC
  @inheritProtected()
  @include LeanRC::NamespaceModuleMixin

  @root __dirname

  @const ANIMATE_ROBOT: Symbol 'animateRobot'
  @const ROBOT_SPEAKING: Symbol 'robotSpeaking'


module.exports = TestApp.initialize()
