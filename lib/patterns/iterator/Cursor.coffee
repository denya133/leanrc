# должен имплементировать интерфейс CursorInterface
# является оберткой над обычным массивом

_  = require 'lodash'
RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::Cursor extends RC::CoreObject
    @inheritProtected()
    @implements LeanRC::CursorInterface

    @Module: LeanRC

    ipnCurrentIndex = @private _currentIndex: Number,
      default: 0
    iplArray = @private _array: Array
    ipcRecord = @private _Record: RC::Class

    @public setRecord: Function,
      default: (acRecord)->
        @[ipcRecord] = acRecord
        return @

    @public toArray: Function,
      default: (acRecord = null)->
        while @hasNext()
          @next(acRecord)

    @public next: Function,
      default: (acRecord = null)->
        acRecord ?= @[ipcRecord]
        data = @[iplArray][@[ipnCurrentIndex]]
        @[ipnCurrentIndex]++
        if acRecord?
          if data?
            acRecord.new data
          else
            data
        else
          data

    @public hasNext: Function,
      default: -> not _.isNil @[iplArray][@[ipnCurrentIndex]]

    @public close: Function,
      default: ->
        for item, i in @[iplArray]
          delete @[iplArray][i]
        delete @[iplArray]
        return

    @public count: Function,
      default: -> @[iplArray].length()

    @public forEach: Function,
      default: (lambda, acRecord = null)->
        index = 0
        try
          while @hasNext()
            lambda @next(acRecord), index++
          return
        catch err
          @close()
          throw err

    @public map: Function,
      default: (lambda, acRecord = null)->
        index = 0
        try
          while @hasNext()
            lambda @next(acRecord), index++
        catch err
          @close()
          throw err

    @public filter: Function,
      default: (lambda, acRecord = null)->
        index = 0
        records = []
        try
          while @hasNext()
            record = @next(acRecord)
            if lambda record, index++
              records.push record
          records
        catch err
          @close()
          throw err

    @public find: Function,
      default: (lambda, acRecord = null)->
        index = 0
        _record = null
        try
          while @hasNext()
            record = @next(acRecord)
            if lambda record, index++
              _record = record
              break
          _record
        catch err
          @close()
          throw err

    @public compact: Function,
      default: (acRecord = null)->
        acRecord ?= @[ipcRecord]
        index = 0
        records = []
        try
          while @hasNext()
            rawRecord = @[iplArray].next()
            unless _.isNil rawRecord
              record = acRecord.new rawRecord
              records.push record
          records
        catch err
          @close()
          throw err

    @public reduce: Function,
      default: (lambda, initialValue, acRecord = null)->
        try
          index = 0
          _initialValue = initialValue
          while @hasNext()
            _initialValue = lambda _initialValue, @next(acRecord), index++
          _initialValue
        catch err
          @close()
          throw err

    @public first: Function,
      default: (acRecord = null)->
        try
          if @hasNext()
            @next(acRecord)
          else
            null
        catch err
          @close()
          throw err

    constructor: (acRecord, alArray = null)->
      super arguments...
      @[ipcRecord] = acRecord
      @[iplArray] = alArray


  return LeanRC::Cursor.initialize()
