RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::Filter extends LeanRC::Pipe
    @inheritProtected()

    @Module: LeanRC

    ipoOutput = Symbodl.for 'output'
    ipsMode = @protected mode: String,
      default: LeanRC::FilterControlMessage.FILTER
    ipmFilter = @protected filter: RC::Constants.LAMBDA,
      default: (aoMessage, aoParams)->
    ipoParams = @protected params: Object
    ipsName = @protected name: String

    ipmIsTarget = @protected isTarget: Function,
      args: [LeanRC::PipeMessageInterface]
      return: Boolean
      default: (aoMessage)-> # must be instance of FilterControlMessage
        aoMessage?.getName() is @[ipsName]

    ipmApplyFilter = @protected applyFilter: Function,
      args: [LeanRC::PipeMessageInterface]
      return: LeanRC::PipeMessageInterface
      default: (aoMessage)->
        @[ipmFilter].apply @, [aoMessage, @[ipoParams]]
        return aoMessage

    @public setParams: Function,
      default: (aoParams)->
        @[ipoParams] = aoParams
        return

    @public setFilter: Function,
      default: (amFlter)->
        @[ipmFilter] = amFlter
        return

    @public write: Function,
      default: (aoMessage)->
        vbSuccess = yes
        voOutputMessage = null
        switch aoMessage.getType()
          when LeanRC::PipeMessage.NORMAL
            try
              if @[ipsMode] is LeanRC::FilterControlMessage.FILTER
                voOutputMessage = @[ipmApplyFilter] aoMessage
              else
                voOutputMessage = aoMessage
              vbSuccess = @[ipoOutput].write voOutputMessage
            catch err
              vbSuccess = no
          when LeanRC::FilterControlMessage.SET_PARAMS
            if @[ipmIsTarget] aoMessage
              @setParams aoMessage.getParams()
            else
              vbSuccess = @[ipoOutput].write voOutputMessage
            break
          when LeanRC::FilterControlMessage.SET_FILTER
            if @[ipmIsTarget] aoMessage
              @setFilter aoMessage.getFilter()
            else
              vbSuccess = @[ipoOutput].write voOutputMessage
            break
          when LeanRC::FilterControlMessage.BYPASS, LeanRC::FilterControlMessage.FILTER
            if @[ipmIsTarget] aoMessage
              @[ipsMode] = aoMessage.getType()
            else
              vbSuccess = @[ipoOutput].write voOutputMessage
            break
          else
            vbSuccess = @[ipoOutput].write outputMessage
        return vbSuccess

    constructor: (asName, aoOutput=null, amFlter=null, aoParams=null)->
      super aoOutput
      @[ipsName] = asName
      if amFlter?
        @setFilter amFlter
      if aoParams?
        @setParams aoParams


  return LeanRC::Filter.initialize()
