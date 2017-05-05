

module.exports = (Module) ->
  {
    Application
  } = Module::

  class SchemaApplication extends Application
    @inheritProtected()
    @module Module

    @public @static NAME: String,
      default: 'CucumbersSchema'


  SchemaApplication.initialize()
