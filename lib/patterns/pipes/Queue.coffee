

module.exports = (Module)->
  class Queue extends Module::Pipe
    @inheritProtected()

    @Module: Module

    ipoOutput = Symbol.for '~output'
    ipsMode = @protected mode: String,
      default: Module::QueueControlMessage.SORT
    iplMessages = @protected messages: Array

    ipmSortMessagesByPriority = @protected sortMessagesByPriority: Function,
      args: [Module::PipeMessageInterface, Module::PipeMessageInterface]
      return: Number
      default: (msgA, msgB)->
        vnNum = 0
        if msgA.getPriority() < msgB.getPriority()
          vnNum = -1
        if msgA.getPriority() > msgB.getPriority()
          vnNum = 1
        return vnNum

    ipmStore = @protected store: Function,
      args: [Module::PipeMessageInterface]
      return: Module::NILL
      default: (aoMessage)->
        @[iplMessages] ?= []
        @[iplMessages].push aoMessage
        if @[ipsMode] is Module::QueueControlMessage.SORT
          @[iplMessages].sort @[ipmSortMessagesByPriority]
        return

    ipmFlush = @protected flush: Function,
      args: []
      return: Boolean
      default: ->
        vbSuccess = yes
        @[iplMessages] ?= []
        while (voMessage = @[iplMessages].shift())?
          ok = @[ipoOutput].write voMessage
          unless ok
            vbSuccess = no
        vbSuccess

    @public write: Function,
      default: (aoMessage)->
        vbSuccess = yes
        voOutputMessage = null
        switch aoMessage.getType()
          when Module::PipeMessage.NORMAL
            @[ipmStore] aoMessage
          when Module::QueueControlMessage.FLUSH
            vbSuccess = @[ipmFlush]()
          when Module::QueueControlMessage.SORT, Module::QueueControlMessage.FIFO
            @[ipsMode] = aoMessage.getType()
        return vbSuccess

    @public init: Function,
      default: (aoOutput=null)->
        @super aoOutput


  return Queue.initialize()
