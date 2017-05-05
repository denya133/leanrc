

module.exports = (Module) ->
  {
    ApplicationFacade
  } = Module::

  class LoggerApplication extends Application
    @inheritProtected()
    @module Module

    @public @static NAME: String,
      default: 'Logger'


  LoggerApplication.initialize()
