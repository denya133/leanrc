

module.exports = (Module)->
  {
    NilT, PointerT
    FuncG, ListG, MaybeG
    PipeFittingInterface, PipeMessageInterface
    LineControlMessage: { SORT, FLUSH, FIFO }
    Pipe
  } = Module::

  class Line extends Pipe
    @inheritProtected()
    @module Module

    ipoOutput = PointerT Symbol.for '~output'
    ipsMode = PointerT @protected mode: String,
      default: SORT
    iplMessages = PointerT @protected messages: ListG PipeMessageInterface

    ipmSort = PointerT @protected sortMessagesByPriority: FuncG([
      PipeMessageInterface, PipeMessageInterface
    ], Number),
      default: (msgA, msgB)->
        vnNum = 0
        if msgA.getPriority() < msgB.getPriority()
          vnNum = -1
        if msgA.getPriority() > msgB.getPriority()
          vnNum = 1
        return vnNum

    ipmStore = PointerT @protected store: FuncG(PipeMessageInterface, NilT),
      default: (aoMessage)->
        @[iplMessages] ?= []
        @[iplMessages].push aoMessage
        if @[ipsMode] is SORT
          @[iplMessages].sort @[ipmSort]
        return

    ipmFlush = PointerT @protected flush: FuncG([], Boolean),
      default: ->
        vbSuccess = yes
        @[iplMessages] ?= []
        while (voMessage = @[iplMessages].shift())?
          ok = @[ipoOutput].write voMessage
          unless ok
            vbSuccess = no
        vbSuccess

    @public write: FuncG(PipeMessageInterface, Boolean),
      default: (aoMessage)->
        vbSuccess = yes
        voOutputMessage = null
        switch aoMessage.getType()
          when Module::PipeMessage.NORMAL
            @[ipmStore] aoMessage
          when FLUSH
            vbSuccess = @[ipmFlush]()
          when SORT, FIFO
            @[ipsMode] = aoMessage.getType()
        return vbSuccess

    @public init: FuncG([MaybeG PipeFittingInterface], NilT),
      default: (aoOutput=null)->
        @super aoOutput
        return


    @initialize()
