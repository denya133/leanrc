

module.exports = (Module) ->
  {
    CONFIGURATION
    RESQUE

    SimpleCommand
    BaseConfiguration
    BaseResque
    BaseCollection
    TomatoRecord
  } = Module::

  class PrepareModelCommand extends SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: Function,
      default: ->
        @facade.registerProxy BaseConfiguration.new CONFIGURATION
        @facade.registerProxy BaseResque.new RESQUE
        @facade.registerProxy BaseCollection.new 'TomatosCollection',
          delegate: TomatoRecord


  PrepareModelCommand.initialize()
