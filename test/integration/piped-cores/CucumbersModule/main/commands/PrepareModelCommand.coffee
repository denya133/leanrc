

module.exports = (Module) ->
  {
    CONFIGURATION
    RESQUE
    APPLICATION_RENDERER
    APPLICATION_ROUTER

    SimpleCommand
    MainConfiguration
    MainResque
    MainCollection
    CucumberRecord
    Renderer
    ApplicationRouter
  } = Module::

  class PrepareModelCommand extends SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: Function,
      default: ->
        @facade.registerProxy MainConfiguration.new CONFIGURATION
        @facade.registerProxy MainResque.new RESQUE
        @facade.registerProxy MainCollection.new 'CucumbersCollection',
          delegate: CucumberRecord
        @facade.registerProxy Renderer.new APPLICATION_RENDERER
        @facade.registerProxy ApplicationRouter.new APPLICATION_ROUTER


  PrepareModelCommand.initialize()
