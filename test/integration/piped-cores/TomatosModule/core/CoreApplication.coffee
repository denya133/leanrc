

module.exports = (Module) ->
  {
    ApplicationFacade
  } = Module::
  {
    PipeAwareModule
  } = Module::Pipes::

  class CoreApplication extends PipeAwareModule
    @inheritProtected()
    @module Module

    @public @static NAME: String,
      default: 'TomatosCore'

    @public init: Function,
      default: ->
      @super ApplicationFacade.getInstance CoreApplication.NAME
      @facade.startup @


  CoreApplication.initialize()
