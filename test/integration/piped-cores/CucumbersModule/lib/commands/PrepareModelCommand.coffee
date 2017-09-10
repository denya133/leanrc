

module.exports = (Module) ->
  {
    CONFIGURATION
    RESQUE
    APPLICATION_RENDERER
    APPLICATION_ROUTER
    MIGRATIONS
    TEST_PROXY_NAME

    ApplicationSerializer
    # HttpSerializer
    SimpleCommand
    MainConfiguration
    MainResque
    MigrationsCollection
    MainCollection
    ApplicationGateway
    BaseMigration
    CucumberRecord
    TestProxy
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
        @facade.registerProxy MainCollection.new 'CucumbersCollection',
          delegate: CucumberRecord
          serializer: ApplicationSerializer
        @facade.registerProxy TestProxy.new TEST_PROXY_NAME

        @facade.registerProxy ApplicationRouter.new APPLICATION_ROUTER

        unless voApplication.isLightweight
          @facade.registerProxy Renderer.new APPLICATION_RENDERER

          @facade.registerProxy ApplicationGateway.new 'CucumbersGateway',
            entityName: 'cucumber'
            schema: CucumberRecord.schema
          @facade.registerProxy ApplicationGateway.new 'ItselfGateway',
            entityName: 'info'
            schema: {}
            endpoints: {
              info: Module::ItselfInfoEndpoint
            }


  PrepareModelCommand.initialize()
