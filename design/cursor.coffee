{SELF, NULL} = FoxxMC::Constants

# под вопросом: будет ли курсор отдавать инстансы модели, или простые объекты

class CursorInterface extends Interface
  @private _cursor: Object
  @public setTotal: Function, [total], -> SELF
  @public setLimit: Function, [limit], -> SELF
  @public setOffset: Function, [offset], -> SELF
  @public setCursor: Function, [cursor], -> SELF
  @public toArray: Function, [], -> Object
  @public next: Function, [], -> Object
  @public hasNext: Function, [], -> Boolean
  @public dispose: Function, [], -> NULL
  @public total: Function, [], -> Number
  @public limit: Function, [], -> Number
  @public offset: Function, [], -> Number
  @public count: Function, [], -> Number
  @public length: Function, [], -> Number
  @public forEach: Function, [lambda], -> NULL
  @public map: Function, [lambda], -> Array
  @public filter: Function, [lambda], -> Array
  @public find: Function, [lambda], -> Object
  @public reduce: Function, [lambda, initialValue], -> Object

class Cursor extends CoreObject
  @implements CursorInterface
