

module.exports = (Module) ->
  {
    Application
  } = Module::

  class SchemaApplication extends Application
    @inheritProtected()
    @module Module


  SchemaApplication.initialize()
