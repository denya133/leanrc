


module.exports = (Module)->
  {
    CUSTOM_COMMAND

    Proxy
    DelayableMixin
  } = Module::

  class TestProxy extends Proxy
    @inheritProtected()
    @include DelayableMixin
    @module Module
    @public @static test: Function,
      default: (multitonKey)->
        facade = @Module::Facade.getInstance multitonKey
        facade.sendNotification CUSTOM_COMMAND
        return

  TestProxy.initialize()
