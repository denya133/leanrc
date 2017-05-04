

module.exports = (Module)->
  {
    Configuration
    MemoryConfigurationMixin
  } = Module::

  class BaseConfiguration extends Configuration
    @inheritProtected()
    @include MemoryConfigurationMixin
    @module Module

  BaseConfiguration.initialize()
