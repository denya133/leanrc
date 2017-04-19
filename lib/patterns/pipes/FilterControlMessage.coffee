

module.exports = (Module)->
  class FilterControlMessage extends Module::PipeMessage
    @inheritProtected()

    @Module: Module

    @public @static BASE: String,
      get: -> "#{Module::PipeMessage.BASE}filter-control/"
    @public @static SET_PARAMS: String,
      get: -> "#{@BASE}setparams"
    @public @static SET_FILTER: String,
      get: -> "#{@BASE}setfilter"
    @public @static BYPASS: String,
      get: -> "#{@BASE}bypass"
    @public @static FILTER: String,
      get: -> "#{@BASE}filter"

    ipsName = @protected name: String
    ipmFilter = @protected filter: Module::LAMBDA
    ipoParams = @protected params: Object

    @public setName: Function,
      default: (asName)->
        @[ipsName] = asName
        return
    @public getName: Function,
      default: -> @[ipsName]

    @public setFilter: Function,
      default: (amFilter)->
        @[ipmFilter] = amFilter
        return
    @public getFilter: Function,
      default: -> @[ipmFilter]

    @public setParams: Function,
      default: (aoParams)->
        @[ipoParams] = aoParams
        return
    @public getParams: Function,
      default: -> @[ipoParams]

    @public init: Function,
      default: (asType, asName, amFilter=null, aoParams=null)->
        @super asType
        @setName asName
        @setFilter amFilter
        @setParams aoParams


  FilterControlMessage.initialize()
