CoreObject    = require './CoreObject'

class FoxxMC::Cursor extends CoreObject
  _cursor: null
  Model: null

  constructor: (Model, cursor=null)->
    @Model = Model
    @_cursor = cursor if cursor?
    return

  currentUser: (currentUser = null)->
    @__currentUser = currentUser
    return @

  setTotal: (total)->
    @_total = total
    return @

  setLimit: (limit)->
    @_limit = limit
    return @

  setOffset: (offset)->
    @_offset = offset
    return @

  setModel: (Model)->
    @Model = Model
    return @

  setCursor: (cursor)->
    @_cursor = cursor
    return @

  toArray: (Model = null)->
    while @hasNext()
      @next(Model)

  next: (Model = null)->
    Model ?= @Model
    data = @_cursor.next()
    if Model?
      if data?
        Model.new data, @__currentUser
      else
        data
    else
      data

  hasNext: ()->
    @_cursor.hasNext()

  setBatchSize: ()->
    @_cursor.setBatchSize arguments...

  getBatchSize: ()->
    @_cursor.getBatchSize arguments...

  dispose: ()->
    @_cursor.dispose()

  total: ()->
    @_total ? @count()

  limit: ()->
    @_limit ? 0

  offset: ()->
    @_offset ? 0

  count: ()->
    @_cursor.count arguments...

  @defineProperty 'length',
    get: ()->
      @count()

  getExtra: ()->
    @_cursor.getExtra arguments...

  forEach: (lambda, Model = null)->
    index = 0
    try
      while @hasNext()
        lambda @next(Model), index++
      return
    catch err
      @dispose()
      throw err

  map: (lambda, Model = null)->
    index = 0
    try
      while @hasNext()
        lambda @next(Model), index++
    catch err
      @dispose()
      throw err

  filter: (lambda, Model = null)->
    index = 0
    records = []
    try
      while @hasNext()
        record = @next(Model)
        if lambda record, index++
          records.push record
      records
    catch err
      @dispose()
      throw err

  find: (lambda, Model = null)->
    index = 0
    _record = null
    try
      while @hasNext()
        record = @next(Model)
        if lambda record, index++
          _record = record
          break
      _record
    catch err
      @dispose()
      throw err

  reduce: (lambda, initialValue, Model = null)->
    try
      index = 0
      _initialValue = initialValue
      while @hasNext()
        _initialValue = lambda _initialValue, @next(Model), index++
      _initialValue
    catch err
      @dispose()
      throw err

module.exports = FoxxMC::Cursor.initialize()
