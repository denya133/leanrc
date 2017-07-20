


module.exports = (Module)->
  {
    Proxy
    DelayableMixin
  } = Module::

  class TestProxy extends Proxy
    @inheritProtected()
    @include DelayableMixin
    @module Module
    @public @static test: Function,
      default: ->

  TestProxy.initialize()
