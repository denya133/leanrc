{CucumberEntry} = require('../../../CucumbersModule')::


module.exports = (Module) ->
  {
    CONFIGURATION
    RESQUE

    SimpleCommand
    MainConfiguration
    MainResque
    MainCollection
    CucumbersResource
    TomatoRecord
    CucumberEntry
  } = Module::

  class PrepareModelCommand extends SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: Function,
      default: ->
        @facade.registerProxy MainConfiguration.new CONFIGURATION
        @facade.registerProxy MainResque.new RESQUE
        @facade.registerProxy MainCollection.new 'TomatosCollection',
          delegate: TomatoRecord
        @facade.registerProxy CucumbersResource.new 'CucumbersResource',
          delegate: CucumberEntry


  PrepareModelCommand.initialize()
