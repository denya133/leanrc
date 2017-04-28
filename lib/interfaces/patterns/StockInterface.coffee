# комманда эквивалентная контролеру в рельсах
# в зависимости от сингала, будет запускаться нужный ресурс CucumbersStock
# а в зависимости от типа нотификейшена внутри инстанса ресурса
# будет выполняться нужный экшен (метод) create, update, detail, list, delete

# в случае со стрим-сервером заливку и отдачу файла будет реализовывать платформозависимый код медиатора, а ресурсная команда Uploads этим заниматься не будет. (чтобы медиатор напрямую писал в нужный прокси, и считывал поток так же напрямую из прокси.)


module.exports = (Module)->
  {ANY, NILL} = Module::

  Module.defineInterface (BaseClass) ->
    class StockInterface extends BaseClass
      @inheritProtected()

      @public @virtual entityName: String
      @public @virtual keyName: String
      @public @virtual itemEntityName: String
      @public @virtual listEntityName: String
      @public @virtual collectionName: String
      @public @virtual collection: Module::CollectionInterface

      @public @virtual queryParams: Object
      @public @virtual pathPatams: Object
      @public @virtual currentUserId: String
      @public @virtual headers: Object
      @public @virtual body: Object

      @public @virtual query: Object
      @public @virtual recordId: String
      @public @virtual recordBody: Object


      @public @static @virtual actions: Object
      @public @static @virtual action: Function, # alias for @public
        args: [Object, Object] # nameDefinition, config
        return: String


      @public @async @virtual list: Function,
        args: [Object] # {queryParams, pathPatams, currentUserId, headers, body }
        return: NILL # без return. данные посылаем сигналом
      @public @async @virtual detail: Function,
        args: [Object] # {queryParams, pathPatams, currentUserId, headers, body }
        return: NILL # без return. данные посылаем сигналом
      @public @async @virtual create: Function,
        args: [Object] # {queryParams, pathPatams, currentUserId, headers, body }
        return: NILL # без return. данные посылаем сигналом
      @public @async @virtual update: Function,
        args: [Object] # {queryParams, pathPatams, currentUserId, headers, body }
        return: NILL # без return. данные посылаем сигналом
      @public @async @virtual delete: Function,
        args: [Object] # {queryParams, pathPatams, currentUserId, headers, body }
        return: NILL # без return. данные посылаем сигналом

      @public @async @virtual bulkUpdate: Function,
        args: [Object] # {queryParams, pathPatams, currentUserId, headers, body }
        return: NILL # без return. данные посылаем сигналом
      @public @async @virtual bulkPatch: Function,
        args: [Object] # {queryParams, pathPatams, currentUserId, headers, body }
        return: NILL # без return. данные посылаем сигналом
      @public @async @virtual bulkDelete: Function,
        args: [Object] # {queryParams, pathPatams, currentUserId, headers, body }
        return: NILL # без return. данные посылаем сигналом


    StockInterface.initializeInterface()
