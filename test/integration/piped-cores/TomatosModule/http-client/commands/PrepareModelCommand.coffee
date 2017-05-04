

module.exports = (Module) ->
  {
    CONFIGURATION

    SimpleCommand
    BaseConfiguration
    BaseResource
    TomatoEntry
  } = Module::

  class PrepareModelCommand extends SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: Function,
      default: ->
        @facade.registerProxy BaseConfiguration.new CONFIGURATION,
          #... configs
          url: {
            #...
          }

        @facade.registerProxy BaseResource.new 'TomatosResource',
          delegate: TomatoEntry


  PrepareModelCommand.initialize()
