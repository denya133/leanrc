

module.exports = (Module) ->
  {
    ApplicationFacade
    Application
  } = Module::

  class MainApplication extends Application
    @inheritProtected()
    @module Module

    @public @static NAME: String,
      default: 'CucumbersMain'


  MainApplication.initialize()
