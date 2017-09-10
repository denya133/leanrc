

module.exports = (Module)->
  class Filter extends Module::Pipe
    @inheritProtected()

    @module Module

    ipoOutput = Symbol.for '~output'
    ipsMode = @protected mode: String,
      default: Module::FilterControlMessage.FILTER
    ipmFilter = @protected filter: Module::LAMBDA,
      default: (aoMessage, aoParams)->
    ipoParams = @protected params: Object
    ipsName = @protected name: String

    ipmIsTarget = @protected isTarget: Function,
      args: [Module::PipeMessageInterface]
      return: Boolean
      default: (aoMessage)-> # must be instance of FilterControlMessage
        aoMessage instanceof Module::FilterControlMessage and
          aoMessage?.getName() is @[ipsName]

    ipmApplyFilter = @protected applyFilter: Function,
      args: [Module::PipeMessageInterface]
      return: Module::PipeMessageInterface
      default: (aoMessage)->
        @[ipmFilter].apply @, [aoMessage, @[ipoParams]]
        return aoMessage

    @public setParams: Function,
      default: (aoParams)->
        @[ipoParams] = aoParams
        return

    @public setFilter: Function,
      default: (amFilter)->
        @[ipmFilter] = amFilter
        return

    @public write: Function,
      default: (aoMessage)->
        vbSuccess = yes
        voOutputMessage = null
        switch aoMessage.getType()
          when Module::PipeMessage.NORMAL
            try
              if @[ipsMode] is Module::FilterControlMessage.FILTER
                voOutputMessage = @[ipmApplyFilter] aoMessage
              else
                voOutputMessage = aoMessage
              vbSuccess = @[ipoOutput].write voOutputMessage
            catch err
              vbSuccess = no
          when Module::FilterControlMessage.SET_PARAMS
            if @[ipmIsTarget] aoMessage
              @setParams aoMessage.getParams()
            else
              vbSuccess = @[ipoOutput].write voOutputMessage
            break
          when Module::FilterControlMessage.SET_FILTER
            if @[ipmIsTarget] aoMessage
              @setFilter aoMessage.getFilter()
            else
              vbSuccess = @[ipoOutput].write voOutputMessage
            break
          when Module::FilterControlMessage.BYPASS, Module::FilterControlMessage.FILTER
            if @[ipmIsTarget] aoMessage
              @[ipsMode] = aoMessage.getType()
            else
              vbSuccess = @[ipoOutput].write voOutputMessage
            break
          else
            vbSuccess = @[ipoOutput].write outputMessage
        return vbSuccess

    @public init: Function,
      default: (asName, aoOutput=null, amFilter=null, aoParams=null)->
        @super aoOutput
        @[ipsName] = asName
        if amFilter?
          @setFilter amFilter
        if aoParams?
          @setParams aoParams


  Filter.initialize()
