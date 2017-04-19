

module.exports = (Module)->
  class Application extends Module::CoreObject
    @inheritProtected()

    @Module: Module

    @public @static NAME: String,
      default: 'Application'

    @public init: Function,
      default: (args...)->
        @super args...
        facade = @constructor.Module::ApplicationFacade.getInstance @constructor.Module::Application.NAME
        facade.startup @


  Application.initialize()
