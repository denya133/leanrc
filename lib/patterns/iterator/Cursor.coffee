# должен имплементировать интерфейс CursorInterface
# является оберткой над обычным массивом


# TODO: от Игоря предложение, сделать свойство isClosed

module.exports = (Module)->
  {
    AnyT, NilT, PointerT
    FuncG, MaybeG
    CollectionInterface, CursorInterface
    CoreObject
    Utils: { _ }
  } = Module::

  class Cursor extends CoreObject
    @inheritProtected()
    @implements CursorInterface
    @module Module

    ipnCurrentIndex = PointerT @private currentIndex: Number,
      default: 0
    iplArray = PointerT @private array: Array

    ipoCollection = PointerT @private collection: CollectionInterface

    @public isClosed: Boolean,
      default: false

    @public setCollection: FuncG(CollectionInterface, CursorInterface),
      default: (aoCollection)->
        @[ipoCollection] = aoCollection
        return @

    @public setIterable: FuncG(AnyT, CursorInterface),
      default: (alArray)->
        @[iplArray] = alArray
        return @

    @public @async toArray: FuncG([], Array),
      default: ->
        while yield @hasNext()
          yield @next()

    @public @async next: FuncG([], AnyT),
      default: ->
        data = yield Module::Promise.resolve @[iplArray][@[ipnCurrentIndex]]
        @[ipnCurrentIndex]++
        switch
          when not data?
            yield return data
          when @[ipoCollection]?
            return yield @[ipoCollection].normalize data
          else
            yield return data

    @public @async hasNext: FuncG([], Boolean),
      default: ->
        yield Module::Promise.resolve not _.isNil @[iplArray][@[ipnCurrentIndex]]

    @public @async close: Function,
      default: ->
        for item, i in @[iplArray]
          delete @[iplArray][i]
        delete @[iplArray]
        yield return

    @public @async count: FuncG([], Number),
      default: ->
        array = @[iplArray] ? []
        yield Module::Promise.resolve array.length?() ? array.length

    @public @async forEach: FuncG(Function, NilT),
      default: (lambda)->
        index = 0
        try
          while yield @hasNext()
            yield lambda (yield @next()), index++
          return
        catch err
          yield @close()
          throw err

    @public @async map: FuncG(Function, Array),
      default: (lambda)->
        index = 0
        try
          while yield @hasNext()
            yield lambda (yield @next()), index++
        catch err
          yield @close()
          throw err

    @public @async filter: FuncG(Function, Array),
      default: (lambda)->
        index = 0
        records = []
        try
          while yield @hasNext()
            record = yield @next()
            if yield lambda record, index++
              records.push record
          records
        catch err
          yield @close()
          throw err

    @public @async find: FuncG(Function, AnyT),
      default: (lambda)->
        index = 0
        _record = null
        try
          while yield @hasNext()
            record = yield @next()
            if yield lambda record, index++
              _record = record
              break
          _record
        catch err
          yield @close()
          throw err

    @public @async compact: FuncG([], Array),
      default: ->
        results = []
        try
          while @[ipnCurrentIndex] < yield @count()
            rawResult = @[iplArray][@[ipnCurrentIndex]]
            ++@[ipnCurrentIndex]
            unless _.isEmpty rawResult
              result = switch
                when @[ipoCollection]?
                  yield @[ipoCollection].normalize rawResult
                else
                  rawResult
              results.push result
          yield return results
        catch err
          yield @close()
          throw err

    @public @async reduce: FuncG([Function, AnyT], AnyT),
      default: (lambda, initialValue)->
        try
          index = 0
          _initialValue = initialValue
          while yield @hasNext()
            _initialValue = yield lambda _initialValue, (yield @next()), index++
          _initialValue
        catch err
          yield @close()
          throw err

    @public @async first: FuncG([], MaybeG AnyT),
      default: ->
        try
          result = if yield @hasNext()
            yield @next()
          else
            null
          yield @close()
          yield return result
        catch err
          yield @close()
          throw err

    @public @static @async restoreObject: Function,
      default: ->
        throw new Error "restoreObject method not supported for #{@name}"
        yield return

    @public @static @async replicateObject: Function,
      default: ->
        throw new Error "replicateObject method not supported for #{@name}"
        yield return

    @public init: FuncG([MaybeG(CollectionInterface), MaybeG Array], NilT),
      default: (aoCollection = null, alArray = null)->
        @super arguments...
        @[ipoCollection] = aoCollection
        @[iplArray] = alArray
        return


    @initialize()
