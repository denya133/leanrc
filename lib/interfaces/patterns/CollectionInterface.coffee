

module.exports = (Module)->
  {
    AnyT, NilT
    FuncG, SubsetG, MaybeG, UnionG, ListG
    RecordInterface, CursorInterface
    SerializerInterface, ObjectizerInterface
    ProxyInterface
  } = Module::

  class CollectionInterface extends ProxyInterface
    @inheritProtected()
    @module Module

    @virtual recordHasBeenChanged: FuncG [String, Object]

    # надо определиться с этими двумя пунктами, так ли их объявлять?
    @virtual delegate: SubsetG RecordInterface
    # @virtual serializer: MaybeG SerializerInterface
    # @virtual objectizer: MaybeG ObjectizerInterface

    @virtual collectionName: FuncG [], String
    @virtual collectionPrefix: FuncG [], String
    @virtual collectionFullName: FuncG [MaybeG String], String

    @virtual @async generateId: FuncG [RecordInterface], UnionG String, Number, NilT

    # NOTE: создает инстанс рекорда
    @virtual @async build: FuncG Object, RecordInterface
    # NOTE: создает инстанс рекорда и делает save
    @virtual @async create: FuncG Object, RecordInterface
    # NOTE: обращается к БД
    @virtual @async push: FuncG RecordInterface, RecordInterface

    @virtual @async delete: FuncG [UnionG String, Number]

    @virtual @async destroy: FuncG [UnionG String, Number]
    # NOTE: обращается к БД
    @virtual @async remove: FuncG [UnionG String, Number]

    @virtual @async find: FuncG [UnionG String, Number], MaybeG RecordInterface
    @virtual @async findMany: FuncG [ListG UnionG String, Number], CursorInterface
    # NOTE: обращается к БД
    @virtual @async take: FuncG [UnionG String, Number], MaybeG RecordInterface
    # NOTE: обращается к БД
    @virtual @async takeMany: FuncG [ListG UnionG String, Number], CursorInterface
    # NOTE: обращается к БД
    @virtual @async takeAll: FuncG [], CursorInterface

    @virtual @async update: FuncG [UnionG(String, Number), Object], RecordInterface
    # NOTE: обращается к БД
    @virtual @async override: FuncG [UnionG(String, Number), RecordInterface], RecordInterface

    @virtual @async clone: FuncG RecordInterface, RecordInterface

    @virtual @async copy: FuncG RecordInterface, RecordInterface

    @virtual @async includes: FuncG [UnionG String, Number], Boolean
    # NOTE: количество объектов в коллекции
    @virtual @async length: FuncG [], Number

    # NOTE: нормализация данных из базы
    @virtual @async normalize: FuncG AnyT, RecordInterface
    # NOTE: сериализация рекорда для отправки в базу
    @virtual @async serialize: FuncG RecordInterface, AnyT


    @initialize()
