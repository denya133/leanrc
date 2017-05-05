

module.exports = (Module)->
  {
    Configuration
  } = Module::

  class BaseConfiguration extends Configuration
    @inheritProtected()
    @module Module

  BaseConfiguration.initialize()
