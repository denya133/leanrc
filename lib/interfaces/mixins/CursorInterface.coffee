# интерфейс курсора как такового.
# конкретные курсоры это классы унаследованные от Proxy с использованием нужного платформозависимого миксина поддерживающего этот интерфейс например ArangoCursorMixin
# смысл в том, что наряду с Collection проксями (которые как бы интерфейсы к реально хранимым гдето данным) Cursor прокси должен предоставлять просто другой интерфейс по сути к тем же данным (апи этого интерфейса будет содержать методы next(), ... и др.) а в качестве входного параметра он должен принимать наверно инстанс QueryObject'а и нужен для того, чтобы работать с массивом выходящих данных от некоторого хранилища поштучно (как бы в потоке)

# возможно можно было бы сделать отдельный интерфейс и класс в паттернах с названием Iterator... - не знаю.

{SELF, NILL} = FoxxMC::Constants

# под вопросом: будет ли курсор отдавать инстансы модели, или простые объекты

class CursorInterface extends Interface
  @private _cursor: Object
  # @public setTotal: Function, [total], -> SELF
  # @public setLimit: Function, [limit], -> SELF
  # @public setOffset: Function, [offset], -> SELF
  @public setCursor: Function, [cursor], -> SELF
  @public toArray: Function, [], -> Object
  @public next: Function, [], -> Object
  @public hasNext: Function, [], -> Boolean
  # @public dispose: Function, [], -> NILL
  @public close: Function, [], -> NILL
  # @public total: Function, [], -> Number
  # @public limit: Function, [], -> Number
  # @public offset: Function, [], -> Number
  @public count: Function, [], -> Number
  # @public length: Function, [], -> Number
  @public forEach: Function, [lambda], -> NILL
  @public map: Function, [lambda], -> Array
  @public filter: Function, [lambda], -> Array
  @public find: Function, [lambda], -> Object
  @public reduce: Function, [lambda, initialValue], -> Object
