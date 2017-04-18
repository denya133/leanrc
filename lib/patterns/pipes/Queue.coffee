RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::Queue extends LeanRC::Pipe
    @inheritProtected()

    @Module: LeanRC

    ipoOutput = Symbol.for '~output'
    ipsMode = @protected mode: String,
      default: LeanRC::QueueControlMessage.SORT
    iplMessages = @protected messages: Array

    ipmSortMessagesByPriority = @protected sortMessagesByPriority: Function,
      args: [LeanRC::PipeMessageInterface, LeanRC::PipeMessageInterface]
      return: Number
      default: (msgA, msgB)->
        vnNum = 0
        if msgA.getPriority() < msgB.getPriority()
          vnNum = -1
        if msgA.getPriority() > msgB.getPriority()
          vnNum = 1
        return vnNum

    ipmStore = @protected store: Function,
      args: [LeanRC::PipeMessageInterface]
      return: RC::Constants.NILL
      default: (aoMessage)->
        @[iplMessages] ?= []
        @[iplMessages].push aoMessage
        if @[ipsMode] is LeanRC::QueueControlMessage.SORT
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
          when LeanRC::PipeMessage.NORMAL
            @[ipmStore] aoMessage
          when LeanRC::QueueControlMessage.FLUSH
            vbSuccess = @[ipmFlush]()
          when LeanRC::QueueControlMessage.SORT, LeanRC::QueueControlMessage.FIFO
            @[ipsMode] = aoMessage.getType()
        return vbSuccess

    @public init: Function,
      default: (aoOutput=null)->
        @super aoOutput


  return LeanRC::Queue.initialize()
