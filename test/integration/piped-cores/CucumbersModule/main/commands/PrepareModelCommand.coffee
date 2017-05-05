

module.exports = (Module) ->
  {
    CONFIGURATION
    RESQUE

    SimpleCommand
    MainConfiguration
    MainResque
    MainCollection
    CucumberRecord
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


  PrepareModelCommand.initialize()
