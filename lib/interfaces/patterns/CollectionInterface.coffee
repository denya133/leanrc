RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::CollectionInterface extends RC::Interface
    @inheritProtected()

    @Module: LeanRC

    # надо определиться с этими двумя пунктами, так ли их объявлять?
    @public @static @virtual delegate: RC::Class
    @public @static @virtual serializer: RC::Class

    @public @virtual generateId: Function,
      args: [Object]
      return: [String, RC::Constants.NILL]
    @public @virtual create: Function,
      args: [Object]
      return: LeanRC::RecordInterface
    @public @virtual createDirectly: Function,
      args: [Object]
      return: LeanRC::RecordInterface
    @public @virtual delete: Function,
      args: [String]
      return: LeanRC::RecordInterface
    @public @virtual deleteBy: Function,
      args: [Object] # но возможно надо указать LeanRC::QueryInterface
      return: LeanRC::RecordInterface
    @public @virtual destroy: Function,
      args: [String]
      return: RC::Constants.NILL
    @public @virtual destroyBy: Function,
      args: [Object] # но возможно надо указать LeanRC::QueryInterface
      return: RC::Constants.NILL
    @public @virtual find: Function,
      args: [String]
      return: LeanRC::RecordInterface
    @public @virtual findBy: Function,
      args: [Object] # но возможно надо указать LeanRC::QueryInterface
      return: LeanRC::RecordInterface
    @public @virtual filter: Function,
      args: [Object] # но возможно надо указать LeanRC::QueryInterface
      return: Array  # но возможно надо указать LeanRC::CursorInterface
    @public @virtual update: Function,
      args: [String, Object]
      return: LeanRC::RecordInterface
    @public @virtual updateBy: Function,
      args: [Object, Object] # но возможно надо указать LeanRC::QueryInterface
      return: LeanRC::RecordInterface
    @public @virtual query: Function,
      args: [Object] # но возможно надо указать LeanRC::QueryInterface
      return: RC::Constants.ANY
    @public @virtual copy: Function,
      args: [String] # record id
      return: LeanRC::RecordInterface
    @public @virtual deepCopy: Function,
      args: [String] # record id
      return: LeanRC::RecordInterface
    @public @virtual forEach: Function,
      args: [Function]
      return: RC::Constants.NILL
    @public @virtual map: Function,
      args: [Function]
      return: Array  # но возможно надо указать LeanRC::CursorInterface
    @public @virtual reduce: Function,
      args: [Function, RC::Constants.ANY]
      return: RC::Constants.ANY
    @public @virtual sortBy: Function,
      args: [Object]
      return: Array # но возможно надо указать LeanRC::CursorInterface
    @public @virtual groupBy: Function,
      args: [Object]
      return: Array # но возможно надо указать LeanRC::CursorInterface
    @public @virtual includes: Function,
      args: [String]
      return: Boolean
    @public @virtual exists: Function,
      args: [Object] # но возможно надо указать LeanRC::QueryInterface
      return: Boolean
    @public @virtual length: Function, # количество объектов в коллекции
      args: []
      return: Number
    @public @virtual push: Function,
      args: [[Array, Object]]
      return: Boolean
    @public @virtual normalize: Function,
      args: [Object] # payload
      return: Object # нормализация данных из базы
    @public @virtual serialize: Function,
      args: [String, Object] # id, options
      return: Object # сериализация рекорда для отправки в базу
    @public @virtual unload: Function,
      args: [String] # id
      return: RC::Constants.NILL
    @public @virtual unloadBy: Function,
      args: [Object] # но возможно надо указать LeanRC::QueryInterface
      return: RC::Constants.NILL
    @public @virtual parseQuery: Function, # описание того как стандартный (query object) преобразовать в конкретный запрос к конкретной базе данных
      args: [Object] # но возможно надо указать LeanRC::QueryInterface
      return: RC::Constants.ANY
    @public @virtual executeQuery: Function,
      args: [[Object, String], Object] # query, options
      return: RC::Constants.ANY


  return LeanRC::CollectionInterface.initialize()
