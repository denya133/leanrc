RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::Application extends RC::CoreObject
    @inheritProtected()

    @Module: LeanRC

    @public @static NAME: String,
      default: 'Application'

    constructor: (args...)->
      super args...
      facade = @constructor.Module::ApplicationFacade.getInstance @constructor.Module::Application.NAME
      facade.startup @


  return LeanRC::Application.initialize()
