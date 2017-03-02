# интерфейс к миксину, который должен отвечать за сериализацию отдельной записи при сохранении ее через collection прокси в некоторое хранилище. т.е. за сериализацию отдельных атрибутов и их десериализацию при получении из хранилища.

# для автоматизации и чтобы предотвратить дублирование в таких классах должны определяться общие механизмы, а для отдельных типов данных будет отдельный класс transform

RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::SerializerInterface extends RC::Interface
    @inheritProtected()

    @Module: LeanRC

    @public @virtual collection: LeanRC::CollectionInterface

    @public @virtual normalize: Function, # virtual declaration of method
      args: [RC::Constants.ANY] # payload
      return: [RC::Constants.ANY]
    @public @virtual serialize:   Function, # virtual declaration of method
      args: [LeanRC::RecordInterface, Object] # record, options
      return: Object


  return LeanRC::SerializerInterface.initialize()
