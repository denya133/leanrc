

module.exports = (Module)->
  class Application extends Module::CoreObject
    @inheritProtected()

    @module Module

    @public @static NAME: String,
      default: 'Application'

    @public init: Function,
      default: (args...)->
        @super args...
        facade = @constructor.Module::ApplicationFacade.getInstance @constructor.NAME
        facade.startup @


  Application.initialize()
