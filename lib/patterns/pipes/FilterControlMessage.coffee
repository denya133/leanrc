

module.exports = (Module)->
  {
    NilT, PointerT, LambdaT
    FuncG, MaybeG
    PipeMessage
  } = Module::

  class FilterControlMessage extends PipeMessage
    @inheritProtected()

    @module Module

    @public @static BASE: String,
      get: -> "#{PipeMessage.BASE}filter-control/"
    @public @static SET_PARAMS: String,
      get: -> "#{@BASE}setparams"
    @public @static SET_FILTER: String,
      get: -> "#{@BASE}setfilter"
    @public @static BYPASS: String,
      get: -> "#{@BASE}bypass"
    @public @static FILTER: String,
      get: -> "#{@BASE}filter"

    ipsName = PointerT @protected name: String
    ipmFilter = PointerT @protected filter: LambdaT
    ipoParams = PointerT @protected params: Object

    @public setName: FuncG(String, NilT),
      default: (asName)->
        @[ipsName] = asName
        return

    @public getName: FuncG([], String),
      default: -> @[ipsName]

    @public setFilter: FuncG(Function, NilT),
      default: (amFilter)->
        @[ipmFilter] = amFilter
        return

    @public getFilter: FuncG([], Function),
      default: -> @[ipmFilter]

    @public setParams: FuncG(Object, NilT),
      default: (aoParams)->
        @[ipoParams] = aoParams
        return

    @public getParams: FuncG([], Object),
      default: -> @[ipoParams]

    @public init: FuncG([
      String, String, MaybeG(Function), MaybeG Object
    ], NilT),
      default: (asType, asName, amFilter=null, aoParams=null)->
        @super asType
        @setName asName
        @setFilter amFilter if amFilter?
        @setParams aoParams if aoParams?
        return


    @initialize()
