

module.exports = (Module) ->
  {
    CONFIGURATION
    RESQUE
    APPLICATION_RENDERER
    APPLICATION_ROUTER
    MIGRATIONS

    ApplicationSerializer
    HttpSerializer
    SimpleCommand
    MainConfiguration
    MainResque
    MigrationsCollection
    MainCollection
    ApplicationGateway
    BaseMigration
    ThinHttpCollection
    TomatoRecord
    CucumberRecord
    Renderer
    ApplicationRouter
  } = Module::

  class PrepareModelCommand extends SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: Function,
      default: (aoNotification)->
        voApplication = aoNotification.getBody()
        @facade.registerProxy MainConfiguration.new CONFIGURATION, @Module::ROOT
        @facade.registerProxy MainResque.new RESQUE
        @facade.registerProxy MigrationsCollection.new MIGRATIONS,
          delegate: BaseMigration
          serializer: ApplicationSerializer
        @facade.registerProxy MainCollection.new 'TomatosCollection',
          delegate: TomatoRecord
          serializer: ApplicationSerializer
        @facade.registerProxy ThinHttpCollection.new 'CucumbersCollection',
          delegate: CucumberRecord
          serializer: HttpSerializer

        @facade.registerProxy ApplicationRouter.new APPLICATION_ROUTER

        unless voApplication.isLightweight
          @facade.registerProxy Renderer.new APPLICATION_RENDERER

          @facade.registerProxy ApplicationGateway.new 'TomatosGateway',
            entityName: 'tomato'
            schema: TomatoRecord.schema
          @facade.registerProxy ApplicationGateway.new 'ItselfGateway',
            entityName: 'info'
            schema: {}
            endpoints: {
              info: Module::ItselfInfoEndpoint
            }


  PrepareModelCommand.initialize()
