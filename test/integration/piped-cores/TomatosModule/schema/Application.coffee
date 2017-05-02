

module.exports = (Module) ->
  {
    Application
  } = Module::

  class TomatosSchemaApplication extends Application
    @inheritProtected()
    @module Module

    @public @static NAME: String,
      default: 'TomatosSchema'


  TomatosSchemaApplication.initialize()
