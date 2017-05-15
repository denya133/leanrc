

module.exports = (Module) ->
  {
    CONFIGURATION
    RESQUE
    MIGRATIONS

    SimpleCommand
    Configuration
    BaseResque
    MigrationsCollection
    BaseMigration
    BaseCollection
    CucumberRecord
  } = Module::

  class PrepareModelCommand extends SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: Function,
      default: ->
        @facade.registerProxy Configuration.new CONFIGURATION, @Module::ROOT
        @facade.registerProxy BaseResque.new RESQUE
        @facade.registerProxy MigrationsCollection.new MIGRATIONS,
          delegate: BaseMigration
        @facade.registerProxy BaseCollection.new 'CucumbersCollection',
          delegate: CucumberRecord


  PrepareModelCommand.initialize()