{CucumberEntry} = require('../../../CucumbersModule')::


module.exports = (Module) ->
  {
    CONFIGURATION
    RESQUE
    APPLICATION_RENDERER
    APPLICATION_ROUTER

    SimpleCommand
    Configuration
    MainResque
    MainCollection
    CucumbersResource
    TomatoRecord
    CucumberEntry
    Renderer
    ApplicationRouter
  } = Module::

  class PrepareModelCommand extends SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: Function,
      default: ->
        @facade.registerProxy Configuration.new CONFIGURATION, @Module::ROOT
        @facade.registerProxy MainResque.new RESQUE
        @facade.registerProxy MainCollection.new 'TomatosCollection',
          delegate: TomatoRecord
        @facade.registerProxy CucumbersResource.new 'CucumbersResource',
          delegate: CucumberEntry
        @facade.registerProxy Renderer.new APPLICATION_RENDERER
        @facade.registerProxy ApplicationRouter.new APPLICATION_ROUTER


  PrepareModelCommand.initialize()
