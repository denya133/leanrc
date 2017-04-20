# должен имплементировать интерфейс CursorInterface
# является оберткой над обычным массивом

_  = require 'lodash'
RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::Cursor extends RC::CoreObject
    @inheritProtected()
    @implements LeanRC::CursorInterface

    @Module: LeanRC

    ipnCurrentIndex = @private currentIndex: Number,
      default: 0
    iplArray = @private array: Array
    ipcRecord = @private Record: RC::Class

    @public setRecord: Function,
      default: (acRecord)->
        @[ipcRecord] = acRecord
        return @

    @public @async toArray: Function,
      default: (acRecord = null)->
        while yield @hasNext()
          yield @next acRecord

    @public @async next: Function,
      default: (acRecord = null)->
        acRecord ?= @[ipcRecord]
        data = @[iplArray][@[ipnCurrentIndex]]
        @[ipnCurrentIndex]++
        yield RC::Promise.resolve if acRecord?
          if data?
            acRecord.new data
          else
            data
        else
          data

    @public @async hasNext: Function,
      default: -> yield RC::Promise.resolve not _.isNil @[iplArray][@[ipnCurrentIndex]]

    @public @async close: Function,
      default: ->
        for item, i in @[iplArray]
          delete @[iplArray][i]
        delete @[iplArray]
        yield return

    @public @async count: Function,
      default: -> yield @[iplArray].length()

    @public @async forEach: Function,
      default: (lambda, acRecord = null)->
        index = 0
        try
          while yield @hasNext()
            yield lambda (yield @next acRecord), index++
          return
        catch err
          yield @close()
          throw err

    @public @async map: Function,
      default: (lambda, acRecord = null)->
        index = 0
        try
          while yield @hasNext()
            yield lambda (yield @next acRecord), index++
        catch err
          yield @close()
          throw err

    @public @async filter: Function,
      default: (lambda, acRecord = null)->
        index = 0
        records = []
        try
          while yield @hasNext()
            record = yield @next acRecord
            if yield lambda record, index++
              records.push record
          records
        catch err
          yield @close()
          throw err

    @public @async find: Function,
      default: (lambda, acRecord = null)->
        index = 0
        _record = null
        try
          while yield @hasNext()
            record = yield @next acRecord
            if yield lambda record, index++
              _record = record
              break
          _record
        catch err
          yield @close()
          throw err

    @public @async compact: Function,
      default: (acRecord = null)->
        acRecord ?= @[ipcRecord]
        index = 0
        records = []
        try
          while yield @hasNext()
            rawRecord = yield @[iplArray].next()
            unless _.isNil rawRecord
              record = acRecord.new rawRecord
              records.push record
          records
        catch err
          yield @close()
          throw err

    @public @async reduce: Function,
      default: (lambda, initialValue, acRecord = null)->
        try
          index = 0
          _initialValue = initialValue
          while yield @hasNext()
            _initialValue = yield lambda _initialValue, (yield @next acRecord), index++
          _initialValue
        catch err
          yield @close()
          throw err

    @public @async first: Function,
      default: (acRecord = null)->
        try
          if yield @hasNext()
            yield @next acRecord
          else
            null
        catch err
          yield @close()
          throw err

    @public init: Function,
      default: (acRecord, alArray = null)->
        @super arguments...
        @[ipcRecord] = acRecord
        @[iplArray] = alArray


  return LeanRC::Cursor.initialize()
