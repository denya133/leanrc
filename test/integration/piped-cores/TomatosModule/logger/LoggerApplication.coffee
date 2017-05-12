

module.exports = (Module) ->
  {
    Application
  } = Module::

  class LoggerApplication extends Application
    @inheritProtected()
    @module Module

    @public @static NAME: String,
      default: 'TomatosLogger'


  LoggerApplication.initialize()
