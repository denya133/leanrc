

module.exports = (Module) ->
  {
    ApplicationFacade
  } = Module::

  class HttpClientApplication extends Application
    @inheritProtected()
    @module Module

    @public @static NAME: String,
      default: 'TomatosHttpClient'


  HttpClientApplication.initialize()
