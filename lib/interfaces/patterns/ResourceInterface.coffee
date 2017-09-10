# комманда эквивалентная контролеру в рельсах
# в зависимости от сингала, будет запускаться нужный ресурс CucumbersResource
# а в зависимости от типа нотификейшена внутри инстанса ресурса
# будет выполняться нужный экшен (метод) create, update, detail, list, delete

# в случае со стрим-сервером заливку и отдачу файла будет реализовывать платформозависимый код медиатора, а ресурсная команда Uploads этим заниматься не будет. (чтобы медиатор напрямую писал в нужный прокси, и считывал поток так же напрямую из прокси.)


module.exports = (Module)->
  {
    ANY
    NILL

    CollectionInterface
    ContextInterface
  } = Module::

  Module.defineInterface (BaseClass) ->
    class ResourceInterface extends BaseClass
      @inheritProtected()

      @public @virtual entityName: String
      @public @virtual keyName: String
      @public @virtual itemEntityName: String
      @public @virtual listEntityName: String
      @public @virtual collectionName: String
      @public @virtual collection: CollectionInterface

      @public @virtual context: ContextInterface
      @public @virtual query: Object
      @public @virtual recordId: String
      @public @virtual recordBody: Object


      @public @static @virtual actions: Object
      @public @static @virtual action: Function, # alias for @public
        args: [Object, Object] # nameDefinition, config
        return: String


      @public @async @virtual list: Function,
        args: [Object]
        return: NILL # без return. данные посылаем сигналом
      @public @async @virtual detail: Function,
        args: [Object]
        return: NILL # без return. данные посылаем сигналом
      @public @async @virtual create: Function,
        args: [Object]
        return: NILL # без return. данные посылаем сигналом
      @public @async @virtual update: Function,
        args: [Object]
        return: NILL # без return. данные посылаем сигналом
      @public @async @virtual delete: Function,
        args: [Object]
        return: NILL # без return. данные посылаем сигналом


    ResourceInterface.initializeInterface()
