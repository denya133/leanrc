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
          new global.Promise (resolve, reject)-> resolve yes
          return global.Promise
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
        unless @[ipoError]? or @[ipoData]?
          @[ipoData] = aoData
        return

    @public onRejected: Function,
      default: (aoError)->
        unless @[ipoError]? or @[ipoData]?
          @[ipoError] = aoError
        return

    @public "then": Function,
      default: (onFulfilled, onRejected)->
        if (voPromise = @[ipoPromise])?
          voPromise.then onFulfilled, onRejected
        else
          voResult = undefined
          voError = undefined
          try
            if @[ipoError]?
              if onRejected?
                voResult = onRejected? @[ipoError]
              else
                voError = @[ipoError]
            else
              voResult = onFulfilled? @[ipoData]
          catch err
            voError = err
          new LeanRC::Promise (resolve, reject)->
            if voError?
              reject voError
            else
              resolve voResult

    constructor: (lambda = ->)->
      super arguments...
      if (vcPromise = LeanRC::Promise[cpcPromise])?
        @[ipoPromise] = new vcPromise lambda
      else
        try
          lambda.apply @, [@onFulfilled.bind(@), @onRejected.bind(@)]
        catch e
          @onRejected e


  return LeanRC::Promise.initialize()
