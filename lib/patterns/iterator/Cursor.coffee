# должен имплементировать интерфейс CursorInterface
# является оберткой над обычным массивом

_  = require 'lodash'

# TODO: от Игоря предложение, сделать свойство isClosed

module.exports = (Module)->
  class Cursor extends Module::CoreObject
    @inheritProtected()
    # @implements Module::CursorInterface
    @module Module

    ipnCurrentIndex = @private currentIndex: Number,
      default: 0
    iplArray = @private array: Array

    ipoCollection = @private collection: Module::CollectionInterface

    @public setCollection: Function,
      default: (aoCollection)->
        @[ipoCollection] = aoCollection
        return @

    @public setIterable: Function,
      default: (alArray)->
        @[iplArray] = alArray
        return @

    @public @async toArray: Function,
      default: ->
        while yield @hasNext()
          yield @next()

    @public @async next: Function,
      default: ->
        data = yield Module::Promise.resolve @[iplArray][@[ipnCurrentIndex]]
        @[ipnCurrentIndex]++
        switch
          when not data?
            yield return data
          when @[ipoCollection]?
            yield return @[ipoCollection].normalize data
          else
            yield return data

    @public @async hasNext: Function,
      default: ->
        yield Module::Promise.resolve not _.isNil @[iplArray][@[ipnCurrentIndex]]

    @public @async close: Function,
      default: ->
        for item, i in @[iplArray]
          delete @[iplArray][i]
        delete @[iplArray]
        yield return

    @public @async count: Function,
      default: ->
        array = @[iplArray] ? []
        yield Module::Promise.resolve array.length?() ? array.length

    @public @async forEach: Function,
      default: (lambda)->
        index = 0
        try
          while yield @hasNext()
            yield lambda (yield @next()), index++
          return
        catch err
          yield @close()
          throw err

    @public @async map: Function,
      default: (lambda)->
        index = 0
        try
          while yield @hasNext()
            yield lambda (yield @next()), index++
        catch err
          yield @close()
          throw err

    @public @async filter: Function,
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

    @public @async find: Function,
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

    @public @async compact: Function,
      default: ->
        results = []
        try
          while @[ipnCurrentIndex] < yield @count()
            rawResult = @[iplArray][@[ipnCurrentIndex]]
            ++@[ipnCurrentIndex]
            unless _.isEmpty rawResult
              result = switch
                when @[ipoCollection]?
                  @[ipoCollection].normalize rawResult
                else
                  rawResult
              results.push result
          yield return results
        catch err
          yield @close()
          throw err

    @public @async reduce: Function,
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

    @public @async first: Function,
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

    @public init: Function,
      default: (aoCollection = null, alArray = null)->
        @super arguments...
        @[ipoCollection] = aoCollection
        @[iplArray] = alArray


  Cursor.initialize()
