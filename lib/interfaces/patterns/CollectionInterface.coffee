

module.exports = (Module)->
  {ANY, NILL} = Module::

  Module.defineInterface (BaseClass) ->
    class CollectionInterface extends BaseClass
      @inheritProtected()

      @public @virtual recordHasBeenChanged: Function,
        args: [String, Object]
        return: NILL

      # в классе Proxy от которого будет наследоваться конкретный класс Collection есть метод onRegister в котором можно прописать подключение (или регистрацию) классов Рекорда и Сериализатора

      # надо определиться с этими двумя пунктами, так ли их объявлять?
      @public @virtual delegate: Module::Class
      @public @virtual serializer: Module::Class
      @public @virtual collectionName: Function,
        args: []
        return: String
      @public @virtual collectionPrefix: Function,
        args: []
        return: String
      @public @virtual collectionFullName: Function,
        args: [[String, NILL]]
        return: String
      @public @virtual customFilters: Function, # возвращает установленные кастомные фильтры с учетом наследования
        args: []
        return: Object
      @public @virtual customFilter: Function,
        args: [String, [Object, Function]]
        return: NILL

      @public @virtual generateId: Function,
        args: []
        return: [String, NILL]

      @public @virtual build: Function, # создает инстанс рекорда
        args: [Object]
        return: Module::RecordInterface
      @public @async @virtual create: Function, # создает инстанс рекорда и делает save
        args: [Object]
        return: Module::RecordInterface
      @public @async @virtual push: Function, # обращается к БД
        args: [Module::RecordInterface]
        return: Boolean

      @public @async @virtual delete: Function,
        args: [String]
        return: Module::RecordInterface

      @public @async @virtual destroy: Function,
        args: [String]
        return: NILL
      @public @async @virtual remove: Function, # обращается к БД
        args: [String]
        return: Boolean

      @public @async @virtual find: Function,
        args: [String]
        return: Module::RecordInterface
      @public @async @virtual findMany: Function,
        args: [Array]
        return: Module::CursorInterface
      @public @async @virtual take: Function, # обращается к БД
        args: [String]
        return: Module::CursorInterface
      @public @async @virtual takeMany: Function, # обращается к БД
        args: [Array]
        return: Module::CursorInterface
      @public @async @virtual takeAll: Function, # обращается к БД
        args: []
        return: Module::CursorInterface

      @public @async @virtual replace: Function,
        args: [String, Object]
        return: Module::RecordInterface
      @public @async @virtual override: Function, # обращается к БД
        args: [String, Module::RecordInterface]
        return: Boolean

      @public @async @virtual update: Function,
        args: [String, Object]
        return: Module::RecordInterface
      @public @async @virtual patch: Function, # обращается к БД
        args: [String, Module::RecordInterface]
        return: Boolean

      @public @virtual clone: Function,
        args: [Module::RecordInterface]
        return: Module::RecordInterface

      @public @async @virtual copy: Function,
        args: [Module::RecordInterface]
        return: Module::RecordInterface

      @public @async @virtual includes: Function,
        args: [String]
        return: Boolean
      @public @async @virtual length: Function, # количество объектов в коллекции
        args: []
        return: Number

      @public @virtual normalize: Function,
        args: [ANY] # payload
        return: Module::RecordInterface # нормализация данных из базы
      @public @virtual serialize: Function,
        args: [Module::RecordInterface] # id, options
        return: ANY # сериализация рекорда для отправки в базу


    CollectionInterface.initializeInterface()
