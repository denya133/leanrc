# создаем это не для того, чтобы фоново что-то обрабатывать - тут миграции, это нонсенс
# но для того, чтобы в миграциях можно было обратиться к Resque чтобы создать некоторые очереди в коллекции очередей.


module.exports = (Module)->
  {
    Resque
    MemoryResqueMixin
  } = Module::

  class BaseResque extends Resque
    @inheritProtected()
    @include MemoryResqueMixin
    @module Module


  BaseResque.initialize()
