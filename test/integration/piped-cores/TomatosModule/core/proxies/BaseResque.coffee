# создаем его в Core для того чтобы можно было ставить задачи на обработку


module.exports = (Module)->
  {
    Resque
    MemoryResqueMixin
  } = Module::

  class BaseResque extends Resque
    @inheritProtected()
    @module Module

    @include MemoryResqueMixin


  BaseResque.initialize()
