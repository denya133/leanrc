

module.exports = (Module) ->
  {
    CONFIGURATION
    RESQUE
    APPLICATION_RENDERER
    APPLICATION_ROUTER
    TEST_PROXY_NAME

    SimpleCommand
    Configuration
    MainResque
    MainCollection
    CucumberRecord
    Renderer
    ApplicationRouter
    TestProxy
  } = Module::

  class PrepareModelCommand extends SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: Function,
      default: ->
        @facade.registerProxy Configuration.new CONFIGURATION, @Module::ROOT
        @facade.registerProxy MainResque.new RESQUE
        @facade.registerProxy MainCollection.new 'CucumbersCollection',
          delegate: CucumberRecord
        @facade.registerProxy Renderer.new APPLICATION_RENDERER
        @facade.registerProxy ApplicationRouter.new APPLICATION_ROUTER
        @facade.registerProxy TestProxy.new TEST_PROXY_NAME


  PrepareModelCommand.initialize()
