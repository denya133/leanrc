# здесь должна быть синхронная реализация Промиса. А в ноде будет использоваться нативный класс с тем же интерфейсом.
# внутри этой реализации надо в приватное свойство положить синхронный промис с предпроверкой (если нативный определен - то должен быть положен нативный)

RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::Promise extends RC::CoreObject
    @inheritProtected()
    @implements LeanRC::PromiseInterface

    @Module: LeanRC

    cpcPromise = @private @static Promise: [Function, RC::Constants.NILL],
      get: ->
        try
          new Promise (resolve, reject)-> resolve yes
          return Promise
        catch
          null

    ipoPromise = @private promise: RC::Constants.ANY
    ipoData = @private data: RC::Constants.ANY
    ipoError = @private error: Error

    @public @static all: Function,
      default: (iterable)->
        if (vcPromise = @[cpcPromise])?
          vcPromise.all iterable
        else
          vlResults = []
          voError = null
          iterable.forEach (item)->
            LeanRC::Promise.resolve()
              .then ->
                item
              .then (data)->
                vlResults.push data
              .catch (err)->
                voError = err
          new LeanRC::Promise (resolve, reject)->
            if voError?
              reject voError
            else
              resolve vlResults

    @public @static reject: Function,
      default: (aoError)->
        if (vcPromise = @[cpcPromise])?
          vcPromise.reject iterable
        else
          new LeanRC::Promise (resolve, reject)->
            reject aoError

    @public @static resolve: Function,
      default: (aoData)->
        if (vcPromise = @[cpcPromise])?
          vcPromise.resolve iterable
        else
          new LeanRC::Promise (resolve, reject)->
            resolve aoData

    @public catch: Function,
      default: (onRejected)->
        @then null, onRejected

    @public onFulfilled: Function,
      default: (aoData)->
        @[ipoData] = aoData
        return

    @public onRejected: Function,
      default: (aoError)->
        @[ipoError] = aoError
        return

    @public "then": Function,
      default: (onFulfilled, onRejected)->
        if (voPromise = @[ipoPromise])?
          voPromise.then onFulfilled, onRejected
        else
          voResult = null
          voError = null
          try
            if @[ipoData]?
              voResult = onFulfilled? @[ipoData]
            else if @[ipoError]?
              voResult = onRejected? @[ipoError]
          catch err
            voError = err
          new LeanRC::Promise (resolve, reject)->
            if voError?
              reject voError
            else
              resolve voResult

    constructor: (lambda)->
      super arguments...
      if (vcPromise = @[cpcPromise])?
        @[ipoPromise] = new vcPromise lambda
      else
        lambda.apply @, [@onFulfilled, @onRejected]


  return LeanRC::Promise.initialize()
