

module.exports = (Module) ->
  {
    ApplicationFacade
  } = Module::
  {
    PipeAwareModule
  } = Module::Pipes::

  class HttpClientApplication extends PipeAwareModule
    @inheritProtected()
    @module Module

    @public @static NAME: String,
      default: 'TomatosHttpClient'

    @public init: Function,
      default: ->
      @super ApplicationFacade.getInstance HttpClientApplication.NAME
      @facade.startup @


  HttpClientApplication.initialize()
