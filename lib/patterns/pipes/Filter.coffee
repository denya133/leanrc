

module.exports = (Module)->
  {
    NilT, PointerT, LambdaT
    FuncG, MaybeG
    PipeMessageInterface, PipeFittingInterface
    FilterControlMessage
    PipeMessage: { NORMAL }
    Pipe
  } = Module::
  {
    FILTER
    SET_PARAMS
    SET_FILTER
    BYPASS
  } = FilterControlMessage

  class Filter extends Pipe
    @inheritProtected()

    @module Module

    ipoOutput = PointerT Symbol.for '~output'
    ipsMode = PointerT @protected mode: String,
      default: FILTER
    ipmFilter = PointerT @protected filter: LambdaT,
      default: (aoMessage, aoParams)->
    ipoParams = PointerT @protected params: MaybeG Object
    ipsName = PointerT @protected name: String

    ipmIsTarget = PointerT @protected isTarget: FuncG(PipeMessageInterface, Boolean),
      default: (aoMessage)-> # must be instance of FilterControlMessage
        aoMessage instanceof FilterControlMessage and
          aoMessage?.getName() is @[ipsName]

    ipmApplyFilter = PointerT @protected applyFilter: FuncG(
      PipeMessageInterface, PipeMessageInterface
    ),
      default: (aoMessage)->
        @[ipmFilter].apply @, [aoMessage, @[ipoParams]]
        return aoMessage

    @public setParams: FuncG(Object, NilT),
      default: (aoParams)->
        @[ipoParams] = aoParams
        return

    @public setFilter: FuncG(Function, NilT),
      default: (amFilter)->
        # @[ipmFilter] = amFilter
        Reflect.defineProperty @, ipmFilter,
          value: amFilter
        return

    @public write: FuncG(PipeMessageInterface, Boolean),
      default: (aoMessage)->
        vbSuccess = yes
        voOutputMessage = null
        switch aoMessage.getType()
          when NORMAL
            try
              if @[ipsMode] is FILTER
                voOutputMessage = @[ipmApplyFilter] aoMessage
              else
                voOutputMessage = aoMessage
              vbSuccess = @[ipoOutput].write voOutputMessage
            catch err
              console.log '>>>>>>>>>>>>>>> err', err
              vbSuccess = no
          when SET_PARAMS
            if @[ipmIsTarget] aoMessage
              @setParams aoMessage.getParams()
            else
              vbSuccess = @[ipoOutput].write voOutputMessage
            break
          when SET_FILTER
            if @[ipmIsTarget] aoMessage
              @setFilter aoMessage.getFilter()
            else
              vbSuccess = @[ipoOutput].write voOutputMessage
            break
          when BYPASS, FILTER
            if @[ipmIsTarget] aoMessage
              @[ipsMode] = aoMessage.getType()
            else
              vbSuccess = @[ipoOutput].write voOutputMessage
            break
          else
            vbSuccess = @[ipoOutput].write outputMessage
        return vbSuccess

    @public init: FuncG([
      String, MaybeG(PipeFittingInterface), MaybeG(Function), MaybeG Object
    ], NilT),
      default: (asName, aoOutput=null, amFilter=null, aoParams=null)->
        @super aoOutput
        @[ipsName] = asName
        if amFilter?
          @setFilter amFilter
        if aoParams?
          @setParams aoParams
        return


    @initialize()
