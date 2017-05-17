

module.exports = (Module) ->
  {
    ApplicationFacade
    Application
  } = Module::

  class MainApplication extends Application
    @inheritProtected()
    @module Module


  MainApplication.initialize()
