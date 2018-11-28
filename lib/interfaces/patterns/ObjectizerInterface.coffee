# интерфейс к миксину, который должен отвечать за сериализацию отдельной записи при сохранении ее через collection прокси в некоторое хранилище. т.е. за сериализацию отдельных атрибутов и их десериализацию при получении из хранилища.

# для автоматизации и чтобы предотвратить дублирование в таких классах должны определяться общие механизмы, а для отдельных типов данных будет отдельный класс transform


module.exports = (Module)->
  {
    AnyT
    FuncG, SubsetG, MaybeG
    CollectionInterface, RecordInterface
    Interface
  } = Module::

  class ObjectizerInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual collection: CollectionInterface

    @virtual @async recoverize: FuncG [SubsetG(RecordInterface), MaybeG Object], MaybeG RecordInterface
    @virtual @async objectize: FuncG [MaybeG(RecordInterface), MaybeG Object], MaybeG Object


    @initialize()
