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
  @public toArray: Function, [], -> Object # ????????? нужен буфер # ВОЗВРАЩАЕТ НЕ ПОТОК, А ОБЪЕКТ-РЕЗУЛЬТАТ ([])
  @public next: Function, [], -> Object
  @public hasNext: Function, [], -> Boolean
  # @public dispose: Function, [], -> NILL
  @public close: Function, [], -> NILL
  @public count: Function, [], -> Number

  @public forEach: Function, [lambda], -> NILL
  @public map: Function, [lambda], -> CursorInterface
  @public filter: Function, [lambda], -> CursorInterface
  @public compact: Function, [], -> CursorInterface
  @public slice: Function, [begin, end], -> CursorInterface # ??? begin, end - positive integers only
  @public splice: Function, [start, deleteCount, args...], -> CursorInterface # ????????????
  @public find: Function, [lambda], -> Object # ВОЗВРАЩАЕТ НЕ ПОТОК, А ОБЪЕКТ-РЕЗУЛЬТАТ ({})
  @public reduce: Function, [lambda, initialValue], -> Object # ВОЗВРАЩАЕТ НЕ ПОТОК, А ОБЪЕКТ-РЕЗУЛЬТАТ (простой тип, {}, [])

  # под вопросом????????????
  @public pip: Function, [CursorInterface], -> Array # ????????????
  @public clone: Function, [], -> CursorInterface # ?? нереально, если внутри нативный курсор

  ###############################################################
  # примеры работы исключительно с целым массивом.
  @public fill: Function, [value, start, end], -> CursorInterface # ????????????
  @public push: Function, [args...], -> CursorInterface # ????????????
  @public every: Function, [lambda], -> Boolean # если все возвраты из лямбд yes
  @public some: Function, [lambda], -> Boolean # если хотябы один возврат yes
  @public uniq: Function, [], -> Array # ? как проверить в потоке - нужен буфер # ВОЗВРАЩАЕТ НЕ ПОТОК, А ОБЪЕКТ-РЕЗУЛЬТАТ ([])
  @public includes: Function, [ANY], -> Boolean
  @public first: Function, [], -> Object # возможно лучше объявить как проперти
  @public last: Function, [], -> Object # возможно лучше объявить как проперти
  @public join: Function, [], -> Array # ??? что под этим подразумевается
  @public concat: Function, [], -> Array # ??? а как конкатить потоки???
  @public reverse: Function, [], -> Array # ???????????? нужен буфер # ВОЗВРАЩАЕТ НЕ ПОТОК, А ОБЪЕКТ-РЕЗУЛЬТАТ ([])
  @public pop: Function, [], -> Array # ??? что под этим подразумевается - если в потоке - то эквивалентно просто потоку без последнего элемента, если должно что то быть возвращено из функции - то тут эже тупик потока.
  @public shift: Function, [], -> Array # ??? что под этим подразумевается - если в потоке - то эквивалентно просто потоку без первого элемента, если должно что то быть возвращено из функции - то тут эже тупик потока.
  @public sort: Function, [], -> Array # ???????????? нужен буфер # ВОЗВРАЩАЕТ НЕ ПОТОК, А ОБЪЕКТ-РЕЗУЛЬТАТ ([])
