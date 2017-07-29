

module.exports = (Module)->
  {
    Mediator
    MemoryExecutorMixin
  } = Module::

  class ResqueExecutor extends Mediator
    @inheritProtected()
    @include MemoryExecutorMixin
    @module Module


  ResqueExecutor.initialize()
