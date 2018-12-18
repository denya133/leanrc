

module.exports = (Module)->
  {
    ProxyInterface
  } = Module::

  class ConfigurationInterface extends ProxyInterface
    @inheritProtected()
    @module Module

    @virtual ROOT: String
    @virtual environment: String
    @virtual defineConfigProperties: Function


    @initialize()
