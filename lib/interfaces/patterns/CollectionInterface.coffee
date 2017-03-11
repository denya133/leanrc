RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::CollectionInterface extends RC::Interface
    @inheritProtected()

    @Module: LeanRC

    # под вопросом ???? - вообще говоря прокси должен посылать к ядру сигнал
    @public recordHasBeenChanged: Function, [], -> NILL

    # в классе Proxy от которого будет наследоваться конкретный класс Collection есть метод onRegister в котором можно прописать подключение (или регистрацию) классов Рекорда и Сериализатора

    # надо определиться с этими двумя пунктами, так ли их объявлять?
    @public @virtual delegate: RC::Class
    @public @virtual serializer: RC::Class
    @public @virtual collectionName: Function,
      args: []
      return: String
    @public @virtual collectionPrefix: Function,
      args: []
      return: String
    @public @virtual collectionFullName: Function,
      args: [[String, RC::Constants.NILL]]
      return: String
    @public @virtual customFilters: Function, # возвращает установленные кастомные фильтры с учетом наследования
      args: []
      return: Object
    @public @virtual customFilter: Function,
      args: [String, [Object, Function]]
      return: RC::Constants.NILL

    @public @virtual generateId: Function,
      args: []
      return: [String, RC::Constants.NILL]

    @public @virtual build: Function, # создает инстанс рекорда
      args: [Object]
      return: LeanRC::RecordInterface
    @public @virtual create: Function, # создает инстанс рекорда и делает save
      args: [Object]
      return: LeanRC::RecordInterface
    @public @virtual push: Function, # обращается к БД
      args: [LeanRC::RecordInterface]
      return: Boolean

    @public @virtual delete: Function,
      args: [String]
      return: LeanRC::RecordInterface
    @public @virtual deleteBy: Function,
      args: [Object]
      return: RC::Constants.NILL

    @public @virtual destroy: Function,
      args: [String]
      return: RC::Constants.NILL
    @public @virtual destroyBy: Function,
      args: [Object]
      return: RC::Constants.NILL
    @public @virtual remove: Function, # обращается к БД
      args: [Object]
      return: Boolean

    @public @virtual find: Function,
      args: [String]
      return: LeanRC::RecordInterface
    @public @virtual findBy: Function,
      args: [Object]
      return: LeanRC::CursorInterface
    @public @virtual take: Function, # обращается к БД
      args: [Object]
      return: LeanRC::CursorInterface

    @public @virtual replace: Function,
      args: [String, Object]
      return: LeanRC::RecordInterface
    @public @virtual replaceBy: Function,
      args: [Object, Object]
      return: RC::Constants.NILL
    @public @virtual override: Function, # обращается к БД
      args: [Object, LeanRC::RecordInterface]
      return: Boolean

    @public @virtual update: Function,
      args: [String, Object]
      return: LeanRC::RecordInterface
    @public @virtual updateBy: Function,
      args: [Object, Object]
      return: RC::Constants.NILL
    @public @virtual patch: Function, # обращается к БД
      args: [Object, LeanRC::RecordInterface]
      return: Boolean

    @public @virtual clone: Function,
      args: [LeanRC::RecordInterface]
      return: LeanRC::RecordInterface

    @public @virtual copy: Function,
      args: [LeanRC::RecordInterface]
      return: LeanRC::RecordInterface

    @public @virtual forEach: Function,
      args: [Function]
      return: RC::Constants.NILL
    @public @virtual filter: Function,
      args: [Function]
      return: Array
    @public @virtual map: Function,
      args: [Function]
      return: Array
    @public @virtual reduce: Function,
      args: [Function, RC::Constants.ANY]
      return: RC::Constants.ANY

    @public @virtual includes: Function,
      args: [String]
      return: Boolean
    @public @virtual exists: Function,
      args: [Object]
      return: Boolean
    @public @virtual length: Function, # количество объектов в коллекции
      args: []
      return: Number

    @public @virtual normalize: Function,
      args: [RC::Constants.ANY] # payload
      return: LeanRC::RecordInterface # нормализация данных из базы
    @public @virtual serialize: Function,
      args: [LeanRC::RecordInterface] # id, options
      return: RC::Constants.ANY # сериализация рекорда для отправки в базу


    @public @virtual query: Function,
      args: [[Object, LeanRC::QueryInterface]]
      return: RC::Constants.ANY
    @public @virtual parseQuery: Function, # описание того как стандартный (query object) преобразовать в конкретный запрос к конкретной базе данных
      args: [[Object, LeanRC::QueryInterface]]
      return: [Object, String, LeanRC::QueryInterface]
    @public @virtual executeQuery: Function,
      args: [[Object, String, LeanRC::QueryInterface], Object] # query, options
      return: RC::Constants.ANY


  return LeanRC::CollectionInterface.initialize()
