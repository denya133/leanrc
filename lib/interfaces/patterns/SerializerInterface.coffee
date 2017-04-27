# интерфейс к миксину, который должен отвечать за сериализацию отдельной записи при сохранении ее через collection прокси в некоторое хранилище. т.е. за сериализацию отдельных атрибутов и их десериализацию при получении из хранилища.

# для автоматизации и чтобы предотвратить дублирование в таких классах должны определяться общие механизмы, а для отдельных типов данных будет отдельный класс transform


module.exports = (Module)->
  {ANY, NILL} = Module::

  Module.defineInterface 'SerializerInterface', (BaseClass) ->
    class SerializerInterface extends BaseClass
      @inheritProtected()

      @public @virtual collection: Module::CollectionInterface

      @public @virtual normalize: Function, # virtual declaration of method
        args: [Module::Class, ANY] # payload
        return: [Module::RecordInterface]
      @public @virtual serialize:   Function, # virtual declaration of method
        args: [Module::RecordInterface, Object] # record, options
        return: ANY


    SerializerInterface.initializeInterface()
