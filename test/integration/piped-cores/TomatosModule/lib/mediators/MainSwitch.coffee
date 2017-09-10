

module.exports = (Module)->
  {
    APPLICATION_RENDERER
    APPLICATION_ROUTER

    Switch
  } = Module::

  class MainSwitch extends Switch
    @inheritProtected()
    @module Module

    @public routerName: String,
      default: APPLICATION_ROUTER
    @public jsonRendererName: String,
      default: APPLICATION_RENDERER


  MainSwitch.initialize()
