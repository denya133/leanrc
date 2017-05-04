

module.exports = (Module) ->
  {
    Application
  } = Module::

  class ShellApplication extends Application
    @inheritProtected()
    @module Module

    @public @static NAME: String,
      default: 'TomatosShell'


  ShellApplication.initialize()
