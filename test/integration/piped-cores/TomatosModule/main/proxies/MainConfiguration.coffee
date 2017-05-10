

module.exports = (Module)->
  {
    Configuration
  } = Module::

  class MainConfiguration extends Configuration
    @inheritProtected()
    @module Module

  MainConfiguration.initialize()
